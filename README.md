# 使用 shardingsphere 做 MySQL 的跨库JOIN（联邦查询）

## 背景  

> 微服务下有多个数据库，如：
> 用户服务、产品服务、订单服务，每个服务都有自己的专属数据库。**单体架构**下完全可以通过JOIN操作，
> 一次性将需要的数据查询出来，但**微服务架构**下，数据库分布在不同地方，JOIN操作无法使用，这时候
> 通过sharding-sphere的跨库JOIN操作，就可以实现跨库JOIN

<hr>

## 系统环境

- Docker
- shardingsphere 5.3.1 （shardingsphere 版本之间配置有很大不同，网络上大多是 5.2.x 或 5.1.x 教程都已过时且跑不起来，注意分辨）

## 教程

## 1、跑一个单机版的 shardingsphere 实例 
`bash run_container.sh`  

## 2、进入 shardingsphere 内的 MySQL（端口默认为3307），并创建一个代理数据库  
```
mysql -p -h127.0.0.1 -P3307 -uroot
mysql> CREATE DATABASE testdb;
Query OK, 0 rows affected (6.51 sec)
```

## 3、查看确认数据库是否创建成功（可选）  
```
mysql> SHOW DATABASES;
+-------------+
| schema_name |
+-------------+
| testdb      |
+-------------+
1 row in set (0.04 sec)
```

## 4、选择代理数据库，并设置要联邦查询的数据源 （下述案例中users、products、orders是3个不同的库，3个库可以不在同一台机器上） 

> 5.3.1 - 使用 REGISTER STORAGE UNIT  
> 5.1.1 - 使用 ADD RESOURCE


```
mysql> USE testdb;
Database changed

mysql> REGISTER STORAGE UNIT ds_order(HOST="192.168.0.112",PORT=3306,DB="orders",USER="root",PASSWORD="123456");
Query OK, 0 rows affected (2.47 sec)

mysql> REGISTER STORAGE UNIT ds_user(HOST="192.168.0.112",PORT=3306,DB="users",USER="root",PASSWORD="123456");
Query OK, 0 rows affected (0.29 sec)

mysql> REGISTER STORAGE UNIT ds_product(HOST="192.168.0.112",PORT=3306,DB="products",USER="root",PASSWORD="123456");
Query OK, 0 rows affected (0.25 sec)
``` 

## 5、查看确认数据表是否同步成功（可选）  
```
mysql> SHOW TABLES;
+------------------+------------+
| Tables_in_testdb | Table_type |
+------------------+------------+
| orderitems       | BASE TABLE |
| accounts         | BASE TABLE |
| product_details  | BASE TABLE |
+------------------+------------+
3 rows in set (0.01 sec)
```

## 6、可以跨库、跨实例JOIN啦

> 目前最新版 5.3.1 不支持中文，更新计划显示 5.3.2 会支持中文的条件判断

```
mysql> SELECT orderitems.quantity, accounts.name, accounts.age, product_details.name, product_details.price
FROM orderitems
	INNER JOIN accounts ON orderitems.user_id = accounts.id
	INNER JOIN product_details ON orderitems.product_id = product_details.id
WHERE orderitems.quantity >= 1;
+----------+-----------+------+-----------+---------+
| quantity | name      | age  | name      | price   |
+----------+-----------+------+-----------+---------+
|        1 | 黄xx    |   24 | iPhone 14 | 9999.00 |
|        2 | 张xx    |   23 | iPhone 14 | 9999.00 |
|        1 | 黄xx    |   24 | 华为P20   | 4999.00 |
|        1 | 黄yy    |   44 | 小米13    | 2999.00 |
+----------+-----------+------+-----------+---------+
4 rows in set (0.62 sec)```   