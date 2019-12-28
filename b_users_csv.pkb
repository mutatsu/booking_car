CREATE OR REPLACE PACKAGE b_users_csv
AS
  PROCEDURE check_new_dealers;
  PROCEDURE check_new_shops;
END b_users_csv;
/
CREATE OR REPLACE PACKAGE BODY b_users_csv
AS
  PROCEDURE check_new_dealers
  AS
    cnt NUMBER := 0;
    rec b_dealers_temp%ROWTYPE;
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
          -- HTP.PRINT(
          DBMS_OUTPUT.PUT_LINE(
            'コード: '|| j.dealer_cd ||
            ' 名称: '|| j.dealer_name ||
            ' は新規登録の可能性があります。'
          );
        ELSE
          -- HTP.PRINT(
          DBMS_OUTPUT.PUT_LINE(
            'コード: '|| j.dealer_cd ||
            ' 名称: '|| j.dealer_name ||
            ' は入力間違いの可能性があります。(コードが異なるが、同じ名称の系列が存在します)'
          );
        END IF;
        rec.dealer_cd := j.dealer_cd;
        rec.dealer_name := j.dealer_name;
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
          -- HTP.PRINT(
          DBMS_OUTPUT.PUT_LINE(
            '系列コード: '|| j.dealer_cd ||
            ' 系列名称: '|| j.dealer_name ||
            ' 店舗コード: '|| j.shop_cd ||
            ' 店舗名称: '|| j.shop_name ||
            ' は新規登録の可能性があります。'
          );
        ELSE
          -- HTP.PRINT(
          DBMS_OUTPUT.PUT_LINE(
            '系列コード: '|| j.dealer_cd ||
            ' 系列名称: '|| j.dealer_name ||
            ' 店舗コード: '|| j.shop_cd ||
            ' 店舗名称: '|| j.shop_name ||
            ' は入力間違いの可能性があります。(コードが異なるが、同じ名称の店舗が存在します)'
          );
        END IF;
        rec.dealer_cd := j.dealer_cd;
        rec.dealer_name := j.dealer_name;
        rec.shop_cd := j.shop_cd;
        rec.shop_name := j.shop_name;
        INSERT INTO b_shops_temp VALUES rec;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_new_shops;

END b_users_csv;
/
