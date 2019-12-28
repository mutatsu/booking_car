CREATE OR REPLACE PACKAGE b_stocks_csv
AS
  PROCEDURE check_new_cars;
  PROCEDURE print_new_cars;
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
      SELECT DISTINCT UTL_I18N.TRANSLITERATE(car_name,'hwkatakana_fwkatakana') car_name
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

  PROCEDURE print_new_cars
  AS
    cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO cnt FROM b_cars_temp;
    IF cnt = 0 THEN
      check_new_cars;
    END IF;

    htp.htmlopen;
    htp.headopen;
    htp.headclose;
    htp.bodyopen;

    htp.header(2,'新しい車種確認');
    htp.header(3,'車種');

    FOR i in (
      SELECT car_name,compact_flg,message
        FROM b_cars_temp
    )LOOP
      htp.print(
        '名称: '|| i.car_name ||
        ' 軽自動車かどうか: '|| i.compact_flg ||
        i.message
      );
      htp.br;
    END LOOP;

    htp.bodyclose;
    htp.htmlclose;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END print_new_cars;

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
  BEGIN
    FOR i in (
      SELECT c.car_id,
             -- st.car_name,
             st.dealer_type,
             st.manage_id,
             st.format_name,
             st.color_cd,
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
      -- dealer_type + manage_id 単位で b_stocks を検索
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
               shop_id,
               user_id,
               close_flg
          INTO rec
          FROM b_stocks
         WHERE dealer_type = i.dealer_type
           AND manage_id = i.manage_id;

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
          IF rec.grade != i.grade THEN
            cnt := cnt + 1;
            rec.grade := i.grade;
          END IF;
          IF rec.option_list != i.option_list THEN
            cnt := cnt + 1;
            rec.option_list := i.option_list;
          END IF;
          IF rec.production_date != i.production_date THEN
            IF LENGTHB(i.production_date) != 10 THEN
              RAISE_APPLICATION_ERROR(-20062,'pruduction_date is not valid date.');
            END IF;
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
            IF LENGTHB(i.registration_expiry_date) != 10 THEN
              RAISE_APPLICATION_ERROR(-20063,'registration_expiry_date is not valid date.');
            END IF;
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
            rec.stock_id                 := b_stocks_seq.nextval;
            rec.car_id                   := i.car_id;
            rec.dealer_type              := i.dealer_type;
            rec.manage_id                := i.manage_id;
            rec.format_name              := i.format_name;
            rec.color_cd                 := i.color_cd;
            rec.grade                    := i.grade;
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
