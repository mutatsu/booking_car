CREATE OR REPLACE PACKAGE b_stocks_csv
AS
  PROCEDURE check_new_cars;
  PROCEDURE print_new_cars_stocks;
  PROCEDURE ins_cars(user_id_in IN VARCHAR2);
  PROCEDURE ins_stocks(user_id_in IN VARCHAR2);
  PROCEDURE delete_temp_data;
END b_stocks_csv;
/
CREATE OR REPLACE PACKAGE BODY b_stocks_csv
AS
  PROCEDURE check_new_cars
  AS
    rec b_cars_temp%ROWTYPE;
  BEGIN
    FOR i in (
      -- 半角カタカナのみを全角カタカナ変換して比較
      -- 半角スペースが全角スペースになってしまうので、半角スペースに戻す
      SELECT DISTINCT REPLACE(UTL_I18N.TRANSLITERATE(car_name,'hwkatakana_fwkatakana'),'　',' ') car_name
        FROM b_stocks_temp
       MINUS 
      SELECT car_name
        FROM b_cars
       WHERE delete_flg = 'N'
    )LOOP
      rec.car_name := i.car_name;
      rec.compact_flg := 'N';
      rec.message := '新規登録の可能性があります。';
      INSERT INTO b_cars_temp VALUES rec;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_new_cars;

  PROCEDURE print_new_cars_stocks
  AS
    cnt NUMBER;
    dt DATE;
  BEGIN
    SELECT COUNT(*) INTO cnt FROM b_cars_temp;
    IF cnt = 0 THEN
      check_new_cars;
    END IF;

    htp.htmlopen;
    htp.headopen;
    htp.headclose;
    htp.bodyopen;

    htp.header(2,'新しい車種および在庫No.重複確認');
    htp.header(3,'車種');

    FOR i in (
      SELECT car_name,compact_flg,message
        FROM b_cars_temp
    )LOOP
      htp.print(
        '名称: '|| i.car_name ||
        -- ' 軽自動車かどうか: '|| i.compact_flg ||
        ' '||i.message
      );
      htp.br;
    END LOOP;

    htp.header(3,'在庫番号重複確認');

    FOR i in (
      SELECT car_name, dealer_type, manage_id,COUNT(*) cnt
        FROM b_stocks_temp
       GROUP BY car_name, dealer_type, manage_id
      HAVING COUNT(*) > 1
    )LOOP
      htp.print(
        '車種: '|| i.car_name ||
        ' タイプ: '|| i.dealer_type ||
        ' 在庫番号: '|| i.manage_id ||
        ' 重複数: '||i.cnt
      );
      htp.br;
    END LOOP;

    htp.header(3,'その他日付・フラグ確認');
    -- 取扱タイプ
    cnt := 0;
    FOR i in (
      SELECT dealer_type from b_stocks_temp
       MINUS
      SELECT DISTINCT dealer_type 
        FROM b_dealer_types
       WHERE delete_flg = 'N'
    )LOOP
      cnt := cnt + 1;
    END LOOP;
    IF cnt != 0 THEN
      FOR i in (
        SELECT LISTAGG(dealer_type,',') all_types
          FROM (
        SELECT DISTINCT dealer_type
          FROM b_dealer_types
         WHERE delete_flg = 'N'
        )
      )LOOP
        htp.print(
          '取扱タイプは '|| i.all_types ||' のみをセットしてください'
        );
        htp.br;
      END LOOP;
    END IF;
    -- 展示フラグ
    SELECT COUNT(*) into cnt
      FROM b_stocks_temp
     WHERE exhibit_flg != 'Y';
    IF cnt != 0 THEN
      htp.print(
        '展示フラグは Y のみをセットしてください'
      );
      htp.br;
    END IF;
    FOR i in (
      SELECT production_date,registration_expiry_date
        FROM b_stocks_temp
    )LOOP
      BEGIN
        -- i.production_date 日付チェック
        BEGIN
          dt := TO_DATE(i.production_date,'YYYY/MM/DD');
        EXCEPTION
          WHEN OTHERS THEN
            RAISE;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          htp.print(
            '生産日を確認してください '||i.production_date
          );
          htp.br;
      END;
      BEGIN
        -- i.registration_expiry_date 日付チェック
        BEGIN
          dt := TO_DATE(i.registration_expiry_date,'YYYY/MM/DD');
        EXCEPTION
          WHEN OTHERS THEN
            RAISE;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          htp.print(
            '完切日を確認してください '||i.registration_expiry_date
          );
          htp.br;
      END;
    END LOOP;

    htp.bodyclose;
    htp.htmlclose;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END print_new_cars_stocks;

  PROCEDURE ins_cars(user_id_in IN VARCHAR2)
  AS
    rec b_cars%ROWTYPE;
    cnt NUMBER := 0;
  BEGIN
    FOR i in (
      SELECT car_name,compact_flg
        FROM b_cars_temp
    )LOOP
      rec.car_id      := b_cars_seq.nextval;
      rec.car_name    := i.car_name;
      rec.compact_flg := i.compact_flg;
      rec.display_num := NULL;
      rec.delete_flg  := 'N';
      rec.created     := CURRENT_DATE;
      rec.created_by  := user_id_in;
      rec.updated     := CURRENT_DATE;
      rec.updated_by  := user_id_in;
      INSERT INTO b_cars VALUES rec;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ins_cars;

  PROCEDURE ins_stocks(user_id_in IN VARCHAR2)
  AS
    rec b_stocks%ROWTYPE;
    cnt NUMBER;
    len NUMBER;
    dt DATE;
    opt_arr apex_application_global.vc_arr2;
  BEGIN
    FOR i in (
      SELECT car_name, dealer_type, manage_id,COUNT(*) cnt
        FROM b_stocks_temp
       GROUP BY car_name, dealer_type, manage_id
      HAVING COUNT(*) > 1
    )LOOP
      RAISE_APPLICATION_ERROR(-20064,'car_name + dealer_type + manage_id is duplicated');
    END LOOP;
    FOR i in (
      SELECT c.car_id,
             -- st.car_name,
             st.dealer_type,
             st.manage_id,
             st.format_name,
             DECODE(LENGTHB(st.color_cd),1,'00',2,'0',NULL)||st.color_cd color_cd, -- CSV の先頭0欠落の対処
             st.grade,
             st.option_list,
             st.production_date,
             st.registration_expiry_date,
             st.exhibit_flg,
             st.df_cd,
             st.rank_cd,
             st.measures_comments,
             st.remarks
        FROM b_stocks_temp st, b_cars c
       WHERE st.car_name = c.car_name
         AND c.delete_flg = 'N'
    )LOOP
      -- car_id + dealer_type + manage_id 単位で b_stocks を検索
      -- データが存在するとUPDATE対象。(close_flg = 'Y'のものは更新しない)
      -- データが存在しないとINSERT対象。
      BEGIN
        SELECT stock_id,
               car_id,
               dealer_type,
               manage_id,
               format_name,
               color_cd,
               grade,
               option_list,
               production_date,
               registration_expiry_date,
               exhibit_flg,
               df_cd,
               rank_cd,
               measures_comments,
               remarks,
               in_preparation_flg,
               delete_flg,
               created,
               created_by,
               updated,
               updated_by,
               reservation_date,
               reservation_deadline,
               close_date,
               shop_id,
               user_id,
               close_flg
          INTO rec
          FROM b_stocks
         WHERE dealer_type = i.dealer_type
           AND manage_id = i.manage_id
           AND car_id = i.car_id
        ;

        IF rec.close_flg = 'Y' THEN
          NULL; -- 既に成約しているので更新対象外
        ELSE -- rec.close_flg = 'Y' のELSE
          -- データの内容が同じかどうかを確認。
          -- 同じであれば更新対象外
          cnt := 0;
          IF rec.format_name != i.format_name THEN
            cnt := cnt + 1;
            rec.format_name := i.format_name;
          END IF;
          IF rec.color_cd != i.color_cd THEN
            cnt := cnt + 1;
            rec.color_cd := i.color_cd;
          END IF;
          -- 半角カタカナを全角カタカナに変換
          -- 半角スペースが全角スペースになってしまうので、半角スペースに戻す
          i.grade := REPLACE(UTL_I18N.TRANSLITERATE(i.grade,'hwkatakana_fwkatakana'),'　',' ');
          IF rec.grade != i.grade THEN
            cnt := cnt + 1;
            rec.grade := i.grade;
          END IF;
          -- オプションは 3 byte 文字列をカンマで区切ったもの。
          -- 例: '41F,47B,53D'
          -- 先頭の0文字列が抜けているかどうかを確認
          IF i.option_list IS NOT NULL THEN
            opt_arr := apex_string.string_to_table(i.option_list,',');
            FOR i in 1..opt_arr.LAST
            LOOP
              len := LENGTHB(opt_arr(i));
              CASE len 
                WHEN 1 THEN opt_arr(i) := '00'||opt_arr(i);
                WHEN 2 THEN opt_arr(i) := '0'||opt_arr(i);
                ELSE NULL; -- 何もしない
              END CASE;
            END LOOP;
            i.option_list := apex_string.table_to_string(opt_arr,',');
          END IF;
          IF rec.option_list != i.option_list THEN
            cnt := cnt + 1;
            rec.option_list := i.option_list;
          END IF;
          IF rec.production_date != i.production_date THEN
            BEGIN
              dt := TO_DATE(i.production_date,'YYYY/MM/DD');
            EXCEPTION
              WHEN OTHERS THEN
                RAISE;
            END;
            cnt := cnt + 1;
            rec.production_date := i.production_date;
          END IF;
          IF rec.registration_expiry_date != i.registration_expiry_date THEN
            BEGIN
              dt := TO_DATE(i.registration_expiry_date,'YYYY/MM/DD');
            EXCEPTION
              WHEN OTHERS THEN
                RAISE;
            END;
            cnt := cnt + 1;
            rec.registration_expiry_date := i.registration_expiry_date;
          END IF;
          IF rec.exhibit_flg != i.exhibit_flg THEN
            cnt := cnt + 1;
            rec.exhibit_flg := i.exhibit_flg;
          END IF;
          IF rec.df_cd != i.df_cd THEN
            cnt := cnt + 1;
            rec.df_cd := i.df_cd;
          END IF;
          IF rec.rank_cd != i.rank_cd THEN
            cnt := cnt + 1;
            rec.rank_cd := i.rank_cd;
          END IF;
          IF rec.measures_comments != i.measures_comments THEN
            cnt := cnt + 1;
            rec.measures_comments := i.measures_comments;
          END IF;
          IF rec.remarks != i.remarks THEN
            cnt := cnt + 1; 
            rec.remarks := i.remarks;
          END IF;
  
          IF cnt = 0 THEN
            NULL; -- 内容が同じなので更新対象外
          ELSE -- IF cnt = 0 の ELSE
            BEGIN
              -- 追加で設定するカラム(必要なものだけ)
              rec.updated              := CURRENT_DATE;
              rec.updated_by           := user_id_in;
              UPDATE b_stocks
                 SET ROW = rec
               WHERE stock_id = rec.stock_id;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE;
            END;
          END IF; -- IF cnt = 0 の END IF 
        END IF;  -- IF rec.close_flg = 'Y' の END IF
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            -- i.option_list の調整
            IF i.option_list IS NOT NULL THEN
              opt_arr := apex_string.string_to_table(i.option_list,',');
              FOR i in 1..opt_arr.LAST
              LOOP
                len := LENGTHB(opt_arr(i));
                CASE len 
                  WHEN 1 THEN opt_arr(i) := '00'||opt_arr(i);
                  WHEN 2 THEN opt_arr(i) := '0'||opt_arr(i);
                  ELSE NULL; -- 何もしない
                END CASE;
              END LOOP;
              i.option_list := apex_string.table_to_string(opt_arr,',');
            END IF;
            -- i.production_date 日付チェック
            BEGIN
              dt := TO_DATE(i.production_date,'YYYY/MM/DD');
            EXCEPTION
              WHEN OTHERS THEN
                RAISE;
            END;
            -- i.registration_expiry_date 日付チェック
            BEGIN
              dt := TO_DATE(i.registration_expiry_date,'YYYY/MM/DD');
            EXCEPTION
              WHEN OTHERS THEN
                RAISE;
            END;

            rec.stock_id                 := b_stocks_seq.nextval;
            rec.car_id                   := i.car_id;
            rec.dealer_type              := i.dealer_type;
            rec.manage_id                := i.manage_id;
            rec.format_name              := i.format_name;
            rec.color_cd                 := i.color_cd;
            rec.grade                    := REPLACE(UTL_I18N.TRANSLITERATE(i.grade,'hwkatakana_fwkatakana'),'　',' ');
            rec.option_list              := i.option_list;
            rec.production_date          := i.production_date;
            rec.registration_expiry_date := i.registration_expiry_date;
            rec.exhibit_flg              := i.exhibit_flg;
            rec.df_cd                    := i.df_cd;
            rec.rank_cd                  := i.rank_cd;
            rec.measures_comments        := i.measures_comments;
            rec.remarks                  := i.remarks;
            rec.in_preparation_flg       := 'N';
            rec.delete_flg               := 'N';
            rec.created                  := CURRENT_DATE;
            rec.created_by               := user_id_in;
            rec.updated                  := CURRENT_DATE;
            rec.updated_by               := user_id_in;
            rec.reservation_date         := NULL;
            rec.reservation_deadline     := NULL;
            rec.shop_id                  := NULL;
            rec.user_id                  := NULL;
            rec.close_flg                := 'N';
            INSERT INTO b_stocks VALUES rec;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE;
          END;
        WHEN OTHERS THEN
          RAISE;
      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ins_stocks;

  PROCEDURE delete_temp_data
  AS
  BEGIN
    DELETE FROM b_cars_temp;
    DELETE FROM b_stocks_temp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END delete_temp_data;
END b_stocks_csv;
/
