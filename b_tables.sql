CREATE TABLE b_stocks (
  stock_id                      NUMBER NOT NULL, -- sequence
  car_id                        NUMBER NOT NULL, -- from b_cars
  dealer_type                   VARCHAR2(2) NOT NULL,   -- 取扱系列: N,P,NP
  manage_id                     NUMBER NOT NULL, -- 系列、車種毎の在庫番号
  format_name                   VARCHAR2(200) NOT NULL, -- 型式
  color_cd                      VARCHAR2(20)  NOT NULL, -- 色(マスター無し)
  grade                         VARCHAR2(100) NOT NULL, -- グレード
  option_list                   VARCHAR2(200) , -- 複数のオプションをカンマ区切りで入力
  production_date               VARCHAR2(10) NOT NULL,  -- 生産日(YYYY/MM/DD)
  registration_expiry_date      VARCHAR2(10) NOT NULL,  -- 完切日(YYYY/MM/DD)：完成検査修了証の有効期限が切れる日？
  exhibit_flg                   VARCHAR2(1) , -- 展示有無 展示:Y
  df_cd                         VARCHAR2(20) NOT NULL,  -- DF 例: 05971, C2414 など
  rank_cd                       VARCHAR2(20) NOT NULL,  -- ランク 例: A-1, A-2, D など
  measures_comments             VARCHAR2(4000), -- 対策費
  remarks                       VARCHAR2(4000), -- 備考
  in_preparation_flg            VARCHAR2(1) DEFAULT 'N', -- Y: 準備中（一時的に予約可能物件として表示できなくする）
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  reservation_date              DATE,
  reservation_deadline          DATE,
  close_date                    DATE,
  shop_id                       NUMBER,
  user_id                       VARCHAR2(8),
  close_flg                     VARCHAR2(1) DEFAULT 'N',
  CONSTRAINT b_stocks_pk PRIMARY KEY (stock_id) ENABLE
);
create unique index b_stocks_idx01 on b_stocks(car_id,dealer_type,manage_id);
create sequence b_stocks_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_cars (
  car_id                        NUMBER NOT NULL,
  car_name                      VARCHAR2(200) NOT NULL,
  compact_flg                   VARCHAR2(1) NOT NULL,   -- N:not compact car, Y:compact car
  display_num                   NUMBER,                 -- display order
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_cars_pk PRIMARY KEY (car_id) ENABLE
);
create sequence b_cars_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_dealers (
  dealer_id                     NUMBER NOT NULL,
  dealer_cd                     VARCHAR2(2) NOT NULL,
  dealer_name                   VARCHAR2(200) NOT NULL,
  display_num                   NUMBER,
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_dealers_pk PRIMARY KEY (dealer_id) ENABLE,
  CONSTRAINT b_dealers_uk UNIQUE (dealer_cd) ENABLE
);
create sequence b_dealers_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_dealer_types (
  dealer_type_id                NUMBER NOT NULL,
  dealer_cd                     VARCHAR2(2) NOT NULL,
  dealer_type                   VARCHAR2(3) NOT NULL,
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_dealer_types_pk PRIMARY KEY (dealer_type_id) ENABLE,
  CONSTRAINT b_dealer_types_fk FOREIGN KEY (dealer_cd) REFERENCES b_dealers (dealer_cd) ENABLE
);
create sequence b_dealer_types_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_shops (
  shop_id                       NUMBER NOT NULL,
  shop_cd                       VARCHAR2(3) NOT NULL,
  shop_name                     VARCHAR2(200) NOT NULL,
  dealer_id                     NUMBER NOT NULL,
  display_num                   NUMBER,
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_shops_pk PRIMARY KEY (shop_id) ENABLE,
  CONSTRAINT b_shops_fk FOREIGN KEY (dealer_id) REFERENCES b_dealers (dealer_id) ENABLE
);
create sequence b_shops_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_users (
  user_id                       VARCHAR2(8) NOT NULL, -- LOWER CASE
  user_name                     VARCHAR2(100) NOT NULL,
  shop_id                       NUMBER NOT NULL,
  email_address                 VARCHAR2(100) NOT NULL, -- LOWER CASE
  password                      VARCHAR2(255) NOT NULL,
  password_life_time            NUMBER NOT NULL, -- 単位: 日
  change_password               VARCHAR2(1) DEFAULT 'Y',
  shop_admin_flg                VARCHAR2(1) DEFAULT 'N',
  admin_flg                     VARCHAR2(1) DEFAULT 'N',
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_users_pk PRIMARY KEY (user_id) ENABLE,
  CONSTRAINT b_users_fk FOREIGN KEY (shop_id) REFERENCES b_shops (shop_id) ENABLE
);

CREATE TABLE b_stocks_log (
  log_id                        NUMBER NOT NULL,
  stock_id                      NUMBER NOT NULL, -- sequence
  car_id                        NUMBER NOT NULL, -- from n_cars
  dealer_type                   VARCHAR2(2) NOT NULL,   -- 取扱系列: N,P,NP
  manage_id                     NUMBER NOT NULL, -- 車種毎の管理番号
  format_name                   VARCHAR2(200) NOT NULL, -- 型式
  color_cd                      VARCHAR2(20)  NOT NULL, -- 色(マスター無し)
  grade                         VARCHAR2(100) NOT NULL, -- グレード
  option_list                   VARCHAR2(200) , -- 複数のオプションをカンマ区切りで入力
  production_date               VARCHAR2(10) NOT NULL,  -- 生産日(YYYY/MM/DD)
  registration_expiry_date      VARCHAR2(10) NOT NULL,  -- 完切日(YYYY/MM/DD)：完成検査修了証の有効期限が切れる日？
  exhibit_flg                   VARCHAR2(1) , -- 展示有無 展示:Y
  df_cd                         VARCHAR2(20) NOT NULL,  -- DF 例: 05971, C2414 など
  rank_cd                       VARCHAR2(20) NOT NULL,  -- ランク 例: A-1, A-2, D など
  measures_comments             VARCHAR2(4000), -- 対策費
  remarks                       VARCHAR2(4000), -- 備考
  in_preparation_flg            VARCHAR2(1), -- Y: 準備中（一時的に予約可能物件として表示できなくする）
  reservation_date              DATE,
  reservation_deadline          DATE,
  close_date                    DATE,
  shop_id                       NUMBER,
  user_id                       VARCHAR2(8),
  close_flg                     VARCHAR2(1),
  event_id                      VARCHAR2(1), -- Timeout:0、予約:1、予約キャンセル:2、成約:3、成約取消:4
  event_date                    DATE,
  CONSTRAINT b_stocks_log_pk PRIMARY KEY (log_id) ENABLE
);
create index b_stocks_log_idx01 on b_stocks_log(event_date,shop_id,user_id);
create sequence b_stocks_log_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_codes ( 
  id                            NUMBER        NOT NULL,
  tag                           VARCHAR2(100) NOT NULL,
  name                          VARCHAR2(100) NOT NULL,
  vc                            VARCHAR2(100) ,
  vn                            NUMBER,
  memo                          VARCHAR2(100),
  display_num                   NUMBER,
  delete_flg                    VARCHAR2(1) DEFAULT 'N',
  created                       DATE DEFAULT CURRENT_DATE,
  created_by                    VARCHAR2(100) DEFAULT 'admin',
  updated                       DATE DEFAULT CURRENT_DATE,
  updated_by                    VARCHAR2(100) DEFAULT 'admin',
  CONSTRAINT b_codes_pk PRIMARY KEY (id) ENABLE
);
create index b_codes_idx01 on b_codes(tag,name,vn,vc);
create sequence b_codes_seq start with 1 increment by 1 nocache order;

CREATE TABLE b_users_temp (
  dealer_name                   VARCHAR2(200),
  dealer_cd                     VARCHAR2(2),
  shop_name                     VARCHAR2(200),
  shop_cd                       VARCHAR2(3),
  user_id                       VARCHAR2(8),
  user_name                     VARCHAR2(100),
  email_address                 VARCHAR2(100),
  update_flg                    VARCHAR2(100) -- 「追加」「削除」の文字をいれてもらう 
);

CREATE TABLE b_dealers_temp (
  dealer_cd                     VARCHAR2(2) NOT NULL,
  dealer_name                   VARCHAR2(200) NOT NULL,
  message                       VARCHAR2(1000)
);

CREATE TABLE b_shops_temp (
  dealer_cd                     VARCHAR2(2) NOT NULL,
  dealer_name                   VARCHAR2(200) NOT NULL,
  shop_cd                       VARCHAR2(3) NOT NULL,
  shop_name                     VARCHAR2(200) NOT NULL,
  message                       VARCHAR2(1000)
);

CREATE TABLE b_stocks_temp (
  car_name                      VARCHAR2(200),
  dealer_type                   VARCHAR2(2),   -- car_name + dealer_type + manage_id で一意
  manage_id                     NUMBER,        -- 
  format_name                   VARCHAR2(200),
  color_cd                      VARCHAR2(20),
  grade                         VARCHAR2(100),
  option_list                   VARCHAR2(200),
  production_date               VARCHAR2(10),
  registration_expiry_date      VARCHAR2(10),
  exhibit_flg                   VARCHAR2(1),
  df_cd                         VARCHAR2(20),
  rank_cd                       VARCHAR2(20),
  measures_comments             VARCHAR2(4000),
  remarks                       VARCHAR2(4000)
);

CREATE TABLE b_cars_temp (
  car_name                      VARCHAR2(200) NOT NULL,
  compact_flg                   VARCHAR2(1) NOT NULL,
  message                       VARCHAR2(1000)
);

CREATE OR REPLACE VIEW b_users_temp_v
(
"系列",
"系列コード",
"店",
"店コード",
"ユーザーID",
"ユーザー名",
"メールアドレス",
"追加/削除"
)AS
SELECT
dealer_name,
dealer_cd,
shop_name,
shop_cd,
user_id,
user_name,
email_address,
update_flg
FROM b_users_temp
;

CREATE OR REPLACE VIEW b_stocks_temp_v
(
"車名",
"取扱タイプ",
"在庫番号",
"型式",
"カラー",
"グレード",
"オプション",
"生産日",
"完切日",
"展示",
"DF",
"ランク",
"対策費",
"状況"
)AS
SELECT
car_name,
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
remarks
FROM b_stocks_temp
;