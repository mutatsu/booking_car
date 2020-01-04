-- b_dealers
insert into b_dealers (dealer_id, dealer_cd, dealer_name, display_num) values(b_dealers_seq.nextval,'P','京都トヨペット',1);
insert into b_dealers (dealer_id, dealer_cd, dealer_name, display_num) values(b_dealers_seq.nextval,'N','ネッツトヨタ京華',2);

-- b_dealer_types
insert into b_dealer_types (dealer_type_id, dealer_cd, dealer_type) values(b_dealer_types_seq.nextval,'P','P');
insert into b_dealer_types (dealer_type_id, dealer_cd, dealer_type) values(b_dealer_types_seq.nextval,'P','NP');
insert into b_dealer_types (dealer_type_id, dealer_cd, dealer_type) values(b_dealer_types_seq.nextval,'N','N');
insert into b_dealer_types (dealer_type_id, dealer_cd, dealer_type) values(b_dealer_types_seq.nextval,'N','NP');

-- b_shops
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'01','P本部',99);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,'02','N本部',99);

insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'10','七条本店',1);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'11','北店',2);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'12','岡崎店',3);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'13','カドノ店',4);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'14','桂店',5);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'15','山科店',6);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'16','伏見店',7);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'17','桃山店',8);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'18','U-mix',9);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'19','Custom Garage',10);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'20','亀岡店',11);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'21','舞鶴店',12);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'22','峰山店',13);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'23','福知山店',14);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'24','マイカーガーデン',15);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'25','乙訓店',16);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'26','城陽店',17);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'27','久御山店',18);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'28','木津川台店',19);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,1,'29','レクサス西大路',20);

insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,33,'高野店', 1);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,34,'カドノ店', 2);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,31,'吉祥院店', 3);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,35,'山科店', 4);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,36,'伏見店', 5);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,51,'宇治店', 6);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,52,'久御山店', 7);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,53,'木津川台店', 8);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,54,'福知山店', 9);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,55,'舞鶴店', 10);
insert into b_shops (shop_id,dealer_id,shop_cd,shop_name,display_num)values(b_shops_seq.nextval,2,56,'京丹後店', 11);

-- b_users
INSERT INTO b_users (shop_id,user_id,email_address,user_name,password,admin_flg,password_life_time)
VALUES (1,'admin01','admin01@foo.com','管理者01',dbms_obfuscation_toolkit.md5(input_string => 'Welcome01'),'Y',0);
INSERT INTO b_users (shop_id,user_id,email_address,user_name,password,admin_flg,password_life_time)
VALUES (2,'admin02','admin02@foo.com','管理者02',dbms_obfuscation_toolkit.md5(input_string => 'Welcome01'),'Y',0);

INSERT INTO b_users (shop_id,user_id,email_address,user_name,password,admin_flg,password_life_time)
VALUES (3,'user03','user03@foo.com','利用者03',dbms_obfuscation_toolkit.md5(input_string => 'Welcome01'),'N',180);
INSERT INTO b_users (shop_id,user_id,email_address,user_name,password,admin_flg,password_life_time)
VALUES (4,'user04','user04@foo.com','利用者04',dbms_obfuscation_toolkit.md5(input_string => 'Welcome01'),'N',180);

-- b_cars
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'アクア','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴィッツ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カローラ スポーツ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'スペイド','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'タンク','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'パッソ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ポルテ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヤリス','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ルーミー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'アルファード','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴェルファイア','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴォクシー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'エスクァイア','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'グランエース','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'シエンタ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ノア','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ハイエース ワゴン','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'アリオン','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カムリ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カローラ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カローラ アクシオ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'クラウン','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'センチュリー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プリウス','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プリウスPHV','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プレミオ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'MIRAI','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カローラ ツーリング','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'カローラ フィールダー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プリウスα','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'C-HR','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ハイラックス','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ハリアー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ライズ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'RAV4','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ランドクルーザー','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ランドクルーザー プラド','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'コペン GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'スープラ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'86','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'アクア GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴィッツ GR','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴィッツ GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ヴォクシー GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'コペン GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'C-HR GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'スープラ','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ノア GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'86 GR','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'86 GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ハリアー GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プリウスα GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'プリウスPHV GR SPORT','N');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ピクシス エポック','Y');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ピクシス ジョイ','Y');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ピクシス トラック','Y');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ピクシス バン','Y');
insert into b_cars (car_id,car_name,compact_flg)values(b_cars_seq.nextval,'ピクシス メガ','Y');

-- b_codes
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'DELETE_FLG',' ','N',1,'削除フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'DELETE_FLG','削除','Y',2,'削除フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'USERS$ADMIN_FLG',' ','N',1,'管理者フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'USERS$ADMIN_FLG','管理者','Y',2,'管理者フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'USERS$CHANGE_PASSWORD','変更なし','N',1,'次回パスワード変更フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'USERS$CHANGE_PASSWORD','次回変更','Y',2,'次回パスワード変更フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'CARS$COMPACT_FLG',' ','N',1,'軽自動車フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'CARS$COMPACT_FLG','軽','Y',2,'軽自動車フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'STOCKS$IN_PREPARATION_FLG',' ','N',1,'準備中フラグ');
insert into b_codes (id, tag, name, vc,display_num,memo)values(b_codes_seq.nextval,'STOCKS$IN_PREPARATION_FLG','準備中','Y',2,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','TIMEOUT',0,0,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','予約',1,1,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','予約取消',2,2,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','受注',3,3,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','受注取消',4,4,'準備中フラグ');
insert into b_codes (id, tag, name, vn,display_num,memo)values(b_codes_seq.nextval,'STOCKS_LOG$EVENT_ID','予約延長',5,5,'準備中フラグ');