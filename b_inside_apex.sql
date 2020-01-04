-- 認可スキーム
admin_only
exists sql問い合わせ
SELECT user_id FROM b_users WHERE admin_flg = 'Y' AND delete_flg = 'N' AND LOWER(user_ID) = LOWER( :APP_USER )
adminアクセス権限がありません。

shop_admin_only
exists sql問い合わせ
SELECT user_id FROM b_users WHERE shop_admin_flg = 'Y' AND delete_flg = 'N' AND LOWER(user_ID) = LOWER( :APP_USER )
shop_adminアクセス権限がありません。

-- LOV
DEALER_NAME
SELECT DECODE(d.delete_flg,'Y','削:',NULL)||
       d.dealer_name, d.dealer_id
  FROM b_dealers d
 ORDER BY d.display_num,d.dealer_id
;

SHOP_NAME
SELECT DECODE(s.delete_flg,'Y','削:',NULL)||
       s.shop_name, s.shop_id
  FROM b_shops s
 ORDER BY s.display_num,s.shop_id
;

DEALER_SHOP_NAME
SELECT d.dealer_name||' '|| s.shop_name v, s.shop_id r
  FROM b_shops s, b_dealers d
 WHERE s.dealer_id = d.dealer_id
 ORDER BY d.display_num,s.display_num,d.dealer_id,s.shop_id
;

CAR_NAME
SELECT DECODE(delete_flg,'Y','削:',NULL)||
       car_name v, car_id r
  FROM b_cars 
 ORDER BY display_num,car_id
;

USER_NAME
SELECT user_name v, user_id r
  FROM b_users 
;

DEALER_TYPES
SELECT DISTINCT d.dealer_type v, d.dealer_type r
  FROM b_dealer_types d
 WHERE d.delete_flg = 'N'
 ORDER BY d.dealer_type
;

DEALER_CD
SELECT DISTINCT d.dealer_cd v, d.dealer_cd r
  FROM b_dealers d
 WHERE d.delete_flg = 'N'
;

DELETE_FLG
SELECT name AS d, vc AS r
  FROM b_codes
 WHERE tag='DELETE_FLG'
 ORDER BY display_num;


USERS$ADMIN_FLG
SELECT name AS d, vc AS r
  FROM b_codes
 WHERE tag='USERS$ADMIN_FLG'
 ORDER BY display_num;

USERS$CHANGE_PASSWORD
SELECT name AS d, vc AS r
  FROM b_codes
 WHERE tag='USERS$CHANGE_PASSWORD'
 ORDER BY display_num;

STOCK_CAR_NAME
SELECT c.car_name d, c.car_id r
  FROM b_cars c,(
      SELECT DISTINCT st.car_id 
        FROM b_stocks st,
             b_dealers d,
             b_dealer_types dt,
             b_users u,
             b_shops sp
       WHERE u.user_id = LOWER(:APP_USER)
         AND u.shop_id = sp.shop_id
         AND sp.dealer_id = d.dealer_id
         AND d.dealer_cd = dt.dealer_cd
         AND dt.dealer_type = st.dealer_type
         AND d.delete_flg = 'N'
         AND dt.delete_flg = 'N'
         AND u.delete_flg = 'N'
         AND sp.delete_flg = 'N'
         AND st.delete_flg = 'N'
  ) s
 WHERE c.car_id = s.car_id
   AND c.delete_flg = 'N'
 ORDER BY c.car_name
;

CARS$COMPACT_FLG
SELECT name AS d, vc AS r
  FROM b_codes
 WHERE tag='CARS$COMPACT_FLG'
 ORDER BY display_num;

YYYYMM_LISTS
SELECT yyyymm_str d,
       yyyymmdd_dt r
  FROM TABLE (
    b_common.ret_yyyymm(CURRENT_DATE, 12)
  );

STOCKS_LOG$EVENT_ID
SELECT name AS d, vn AS r
  FROM b_codes
 WHERE tag='STOCKS_LOG$EVENT_ID'
 ORDER BY display_num;
-- 
