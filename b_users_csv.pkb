CREATE OR REPLACE PACKAGE b_users_csv
AS
  PROCEDURE check_new_dealers;
  PROCEDURE check_new_shops;
  PROCEDURE print_new_dealers_shops;
  PROCEDURE ins_dealers(user_id_in IN VARCHAR2);
  PROCEDURE ins_shops(user_id_in IN VARCHAR2);
  PROCEDURE ins_users(user_id_in IN VARCHAR2);
  PROCEDURE delete_temp_data;
END b_users_csv;
/
CREATE OR REPLACE PACKAGE BODY b_users_csv
AS
  PROCEDURE check_new_dealers
  AS
    cnt NUMBER := 0;
    rec b_dealers_temp%ROWTYPE;
    msgs b_dealers_temp.message%TYPE;
  BEGIN
    FOR i in (
      SELECT DISTINCT dealer_cd
        FROM b_users_temp
       MINUS 
      SELECT dealer_cd
        FROM b_dealers
       WHERE delete_flg = 'N'
    )LOOP
      FOR j in (
          SELECT dealer_cd, dealer_name
            FROM b_users_temp
           WHERE dealer_cd = i.dealer_cd
      )LOOP
        SELECT COUNT(*) INTO cnt FROM b_dealers
         WHERE dealer_name = j.dealer_name
           AND delete_flg = 'N';
        IF cnt = 0 THEN
          msgs := 
            '新規登録の可能性があります。';
        ELSE
          msgs :=
            '入力間違いの可能性があります。(系列コードが異なるが、同じ名称の系列が存在します)';
        END IF;
        rec.dealer_cd := j.dealer_cd;
        rec.dealer_name := j.dealer_name;
        rec.message := msgs;
        INSERT INTO b_dealers_temp VALUES rec;
      END Loop;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_new_dealers;

  PROCEDURE check_new_shops
  AS
    cnt NUMBER;
    rec b_shops_temp%ROWTYPE;
    msgs b_shops_temp.message%TYPE;
  BEGIN
    FOR i in (
      -- Excel で加工すると '01' が '1' になってしまうことへの対応
      SELECT DISTINCT dealer_cd, DECODE(LENGTHB(shop_cd),1,'0',NULL)||shop_cd shop_cd
        FROM b_users_temp
       MINUS 
      SELECT d.dealer_cd, s.shop_cd
        FROM b_dealers d, b_shops s
       WHERE d.dealer_id = s.dealer_id
         AND d.delete_flg = 'N'
         AND s.delete_flg = 'N'
    )LOOP
      FOR j in (
        SELECT DISTINCT dealer_cd,dealer_name,shop_cd,shop_name
          FROM b_users_temp
         WHERE dealer_cd = i.dealer_cd
           AND shop_cd = i.shop_cd
      )LOOP
        SELECT count(*) INTO cnt 
          FROM b_shops
         WHERE shop_name = j.shop_name
           AND shop_cd != j.shop_cd
           AND delete_flg = 'N';
        IF cnt = 0 THEN
          msgs :=
            '新規登録の可能性があります。';
        ELSE
          msgs := 
            '入力間違いの可能性があります。(店コードが異なるが、同じ名称の店舗が存在します)';
        END IF;
        rec.dealer_cd := j.dealer_cd;
        rec.dealer_name := j.dealer_name;
        rec.shop_cd := j.shop_cd;
        rec.shop_name := j.shop_name;
        rec.message := msgs;
        INSERT INTO b_shops_temp VALUES rec;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_new_shops;

  PROCEDURE print_new_dealers_shops
  AS
    cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO cnt FROM b_dealers_temp;
    IF cnt = 0 THEN
      check_new_dealers;
    END IF;
    SELECT COUNT(*) INTO cnt FROM b_shops_temp;
    IF cnt = 0 THEN
      check_new_shops;
    END IF;

    htp.htmlopen;
    htp.headopen;
    htp.headclose;
    htp.bodyopen;

    htp.header(2,'新しい系列/店舗確認');
    htp.header(3,'系列');

    FOR i in (
      SELECT dealer_cd,dealer_name,message
        FROM b_dealers_temp
    )LOOP
      htp.print(
        '系列コード: '|| i.dealer_cd ||
        ' 系列名称: '|| i.dealer_name ||
        i.message
      );
      htp.br;
    END LOOP;

    htp.header(3,'店舗');

    FOR i in (
      SELECT dealer_cd,dealer_name,shop_cd,shop_name,message
        FROM b_shops_temp
    )LOOP
      htp.print(
        '系列コード: '|| i.dealer_cd ||
        ' 系列名称: '|| i.dealer_name ||
        ' 店コード: '|| i.shop_cd ||
        ' 店名称: '|| i.shop_name ||
        i.message
      );
      htp.br;
    END LOOP;

    htp.bodyclose;
    htp.htmlclose;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END print_new_dealers_shops;

  PROCEDURE ins_dealers(user_id_in IN VARCHAR2)
  AS
    rec b_dealers%ROWTYPE;
    cnt NUMBER := 0;
  BEGIN
    FOR i in (
      SELECT dealer_cd,dealer_name
        FROM b_dealers_temp
    )LOOP
      rec.dealer_id   := b_dealers_seq.nextval;
      rec.dealer_cd   := i.dealer_cd;
      rec.dealer_name := i.dealer_name;
      rec.display_num := NULL;
      rec.delete_flg  := 'N';
      rec.created     := CURRENT_DATE;
      rec.created_by  := user_id_in;
      rec.updated     := CURRENT_DATE;
      rec.updated_by  := user_id_in;
      INSERT INTO b_dealers VALUES rec;
    END LOOP;
    -- dealer_cd が一意であることを確認
    -- 一意でなければ RAISE = 失敗 = rollback
    FOR i in (
      SELECT dealer_cd,COUNT(*) 
        FROM b_dealers
       WHERE delete_flg = 'N'
       GROUP BY dealer_cd
      HAVING COUNT(*) > 1
    )LOOP
      cnt := cnt + 1;
    END LOOP;
    IF cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20060,'dealer_cd is not only one in b_dealers.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ins_dealers;

  PROCEDURE ins_shops(user_id_in IN VARCHAR2)
  AS
    rec b_shops%ROWTYPE;
    cnt NUMBER := 0;
  BEGIN
    FOR i in (
      SELECT st.shop_cd,
             st.shop_name,
             d.dealer_id
        FROM b_shops_temp st,b_dealers d
       WHERE st.dealer_cd = d.dealer_cd
         AND d.delete_flg = 'N'
    )LOOP
      rec.shop_id     := b_shops_seq.nextval;
      rec.shop_cd     := i.shop_cd;
      rec.shop_name   := i.shop_name;
      rec.dealer_id   := i.dealer_id;
      rec.display_num := NULL;
      rec.delete_flg  := 'N';
      rec.created     := CURRENT_DATE;
      rec.created_by  := user_id_in;
      rec.updated     := CURRENT_DATE;
      rec.updated_by  := user_id_in;
      INSERT INTO b_shops VALUES rec;
    END LOOP;
    -- dealer_cd,shop_cd が一意であることを確認
    -- 一意でなければ RAISE = 失敗 = rollback
    FOR i in (
      SELECT d.dealer_cd,s.shop_cd,COUNT(*)
        FROM b_dealers d, b_shops s
       WHERE d.dealer_id = s.dealer_id
         AND d.delete_flg = 'N'
         AND d.delete_flg = 'N'
       GROUP BY d.dealer_cd,s.shop_cd
      HAVING COUNT(*) > 1
    )LOOP
      cnt := cnt + 1;
    END LOOP;
    IF cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20061,'dealer_cd,shop_cd is not only one in b_shops.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ins_shops;

  PROCEDURE ins_users(user_id_in IN VARCHAR2)
  AS
    rec b_users%ROWTYPE;
    u_id b_users.user_id%TYPE;
    s_id b_users.shop_id%TYPE;
    dflg b_users.delete_flg%TYPE;
    cnt NUMBER;
  BEGIN
    -- ユーザー削除
    FOR i in (
      SELECT ut.user_id,
             -- ut.user_name,
             -- ut.email_address,
             s.shop_id
        FROM b_users_temp ut,
             b_dealers d,
             b_shops s
       WHERE d.dealer_id = s.dealer_id
         AND d.delete_flg = 'N'
         AND s.delete_flg = 'N'
         AND ut.dealer_cd = d.dealer_cd
         AND ut.shop_cd   = s.shop_cd
         AND ut.update_flg = '削除'
    )LOOP
      BEGIN
        UPDATE b_users 
           SET delete_flg = 'Y',
               updated = CURRENT_DATE,
               updated_by = user_id_in
         WHERE user_id = i.user_id
           AND shop_id = i.shop_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL; -- データが無くても無視
        WHEN OTHERS THEN
          RAISE;
      END;
    END LOOP;

    -- ユーザー追加
    FOR i in (
      SELECT ut.user_id,
             ut.user_name,
             ut.email_address,
             s.shop_id
        FROM b_users_temp ut,
             b_dealers d,
             b_shops s
       WHERE d.dealer_id = s.dealer_id
         AND d.delete_flg = 'N'
         AND s.delete_flg = 'N'
         AND ut.dealer_cd = d.dealer_cd
         AND ut.shop_cd   = s.shop_cd
         AND ut.update_flg = '追加'
    )LOOP
      BEGIN
        SELECT user_id,shop_id,delete_flg
          INTO u_id,s_id,dflg 
          FROM b_users
         WHERE user_id = i.user_id;
        BEGIN
          IF dflg = 'N' AND s_id = i.shop_id THEN
            NULL; -- 既に情報が存在するので何もしない
          ELSE
            -- 削除済のものは、再度利用可能とする
            UPDATE b_users 
               SET delete_flg = 'N',
                   shop_id = i.shop_id,
                   updated = CURRENT_DATE,
                   updated_by = user_id_in
             WHERE user_id = i.user_id;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE;
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rec.user_id            := i.user_id;
          rec.user_name          := i.user_name;
          rec.shop_id            := i.shop_id;
          rec.email_address      := i.email_address;
          rec.password           := 
            dbms_obfuscation_toolkit.md5(
              input_string => DBMS_RANDOM.STRING('U',5)
            );
          rec.password_life_time := 180;
          rec.change_password    := 'Y';
          rec.admin_flg          := 'N';
          rec.delete_flg         := 'N';
          rec.created            := CURRENT_DATE;
          rec.created_by         := user_id_in;
          rec.updated            := CURRENT_DATE;
          rec.updated_by         := user_id_in;
          INSERT INTO b_users VALUES rec;
        WHEN OTHERS THEN
          RAISE;
      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ins_users;

  PROCEDURE delete_temp_data
  AS
  BEGIN
    DELETE FROM b_dealers_temp;
    DELETE FROM b_shops_temp;
    DELETE FROM b_users_temp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END delete_temp_data;
END b_users_csv;
/
