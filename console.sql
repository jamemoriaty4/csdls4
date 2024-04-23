create database QLMS;
use QLMS;

create table Category
(
    id     int primary key auto_increment,
    Name   varchar(50) not null,
    Status tinyint check ( Status in (0, 1) )
);

create table Author
(
    id        int primary key auto_increment,
    Name      varchar(100) not null unique,
    TotalBook int default 0
);

create table Book
(
    id          int primary key auto_increment,
    Name        varchar(150) not null,
    Status      tinyint default 1 check ( Status in (0, 1) ),
    Price       float        not null check ( Price >= 100000 ),
    CreatedDate Date,
    CategoryId  int          not null,
    AuthorId    int          not null
);

create table Customer
(
    id         int primary key auto_increment,
    Name       varchar(150) not null,
    Email      varchar(150) not null unique check ( Email like '%@gmail.com' or '%@facebook.com ' or
                                                    '@bachkhoa-aptech.edu.vn'),
    Phone      varchar(50)  not null unique,
    Address    varchar(255),
    CreateDate date,
    Gender     tinyint      not null check ( Gender in (0, 1, 2) ),
    BirthDay   Date         not null
);

CREATE table Ticket
(
    id         int primary key auto_increment,
    CustomerId int not null,
    Status     tinyint default 1 check ( Status in (0, 1, 2, 3)),
    TicketDate DATETIME
);

create table TicketDetail
(
    TicketId    int   not null,
    BookId      int   not null,
    Quantity    int   not null check ( Quantity > 0 ),
    DeposiPrice float not null,
    RentCost    float not null,
    primary key (TicketId, BookId)
);

#Thêm khoá
alter table TicketDetail
    add foreign key fk_TD_TK (TicketId) references Ticket (id),
    add foreign key fk_TD_B (BookId) references Book (id);

alter table Ticket
    add foreign key fk_TK_CT (CustomerId) references Customer (id);

alter table Book
    add foreign key fk_B_C (CategoryId) references Category (id);
alter table Book
    add foreign key fk_B_A (AuthorId) references Author (id);


#Thêm rằng buộc trigger cho ngày thagns năm
CREATE TRIGGER check_current_date
    before insert
    on Book
    for each row
    set new.CreatedDate = curdate();
CREATE TRIGGER check_current_Ticket_Date
    before insert
    on Ticket
    for each row
    set new.TicketDate = now();


create trigger trigger_Customer
    before insert
    on customer
    for each row
begin
    if new.CreateDate <= curdate()
    then
        signal sqlstate '45000' set message_text = 'ngày bán khong bé hơn ngày hiện tại';
    end if;
end;

CREATE TRIGGER trigger_cost
    BEFORE INSERT
    ON qlms.TicketDetail
    FOR EACH ROW
BEGIN
    DECLARE book_price DECIMAL(10, 2);
    SELECT Price
    INTO book_price
    FROM Book
    WHERE Book.ID = NEW.BookID;

    SET NEW.DeposiPrice = book_price;
END;


#import dữ liệu

#Category

insert into Category(id, Name, Status)
values (1, 'Sách', 1);
insert into Category(id, Name, Status)
values (2, 'Báo', 1);
insert into Category(id, Name, Status)
values (3, 'Vở', 1);
insert into Category(id, Name, Status)
values (4, 'Bút', 1);
insert into Category(id, Name, Status)
values (5, 'Laptop', 1);

#Author

insert into Author(id, Name, TotalBook)
VALUES (1, 'Nguyễn Nhật Ánh', 3);
insert into Author(id, Name, TotalBook)
VALUES (2, 'Đỗ Nhật Nam', 3);
insert into Author(id, Name, TotalBook)
VALUES (3, 'Nguyễn Ngọc Thuần', 3);
insert into Author(id, Name, TotalBook)
VALUES (4, 'Bảo Ninh', 3);
insert into Author(id, Name, TotalBook)
VALUES (5, 'Tô Hoài', 3);

#Book
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (1,'Kính vạn hoa',0,900,1,1);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (2,'Cho tôi xin một vé đi tuổi thơ',0,900,1,1);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (3,'Tôi là Bêtô',0,900,1,1);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (4,'NA1',0,900,2,2);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (5,'NA2',0,900,2,2);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (6,'NA3',0,900,2,2);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (7,'NT1',0,900,3,3);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (8,'NT2',0,900,3,3);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (9,'NT3',0,900,3,3);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (10,'BN1',0,900,4,4);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (11,'Bn2',0,900,4,4);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (12,'Bn3',0,900,4,4);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (13,'TH1',0,900,5,5);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (14,'TH2',0,900,5,5);
# insert into Book (id, Name, Status, Price, CategoryId, AuthorId)
# values (15,'TH3',0,900,5,5);
#thêm bằng tool thầy oiiii

# 1.	Lấy ra danh sách Book có sắp xếp giảm dần theo Price gồm các cột sau:
# Id, Name, 	Price, Status, CategoryName, AuthorName, CreatedDate

select BOOk.id, book.Name, Price, book.Status, C.Name, A.Name, CreatedDate
from Book
         join Category C on Book.Status = C.Status
         join Author A on Book.Name = A.Name
order by Price desc;

# 2.	Lấy ra danh sách Category gồm:
# Id, Name, TotalProduct, Status (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )

select Category.Id,
       Category.Name,
       b.Price,
       CASE WHEN Category.Status = 0 THEN 'Ẩn' ELSE 'Hiển thị' END AS Status
from Category
         join Book B on Category.Status = B.Status;

#3	Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address,CreatedDate,
# Gender, BirthDay, Age (Age là cột suy ra từ BirthDay, Gender nếu = 0 là Nam, 1 là Nữ,2 là khác )

select *,
       case when Customer.Gender = 0 THEN 'Nữ' ELSE 'Nam' END AS Gender,
       year(curdate()) - year(Customer.BirthDay)                 Tuoi
from Customer;

# 4.	Truy vấn xóa Author chưa có sách nào
DELETE
FROM Author a
WHERE NOT EXISTS (SELECT 1
                  FROM Book b
                  WHERE b.AuthorId = a.Id);

# 5.	Cập nhật Cột ToalBook trong bảng Auhor = Tổng số Book của mỗi Author theo Id của Author
UPDATE Author a
SET TotalBook = (SELECT COUNT(*)
                 FROM Book b
                 WHERE b.AuthorId = a.Id)
WHERE a.Id IN (SELECT AuthorId
               FROM Book
               GROUP BY AuthorId);

# 1.	View v_getBookInfo thực hiện lấy ra danh sách các Book được mượn nhiều hơn 3 cuốn

CREATE VIEW v_getBookInfo AS
SELECT id,
       name,
       Price,
       count(Quantity)
FROM Book
         left join TicketDetail on Book.id = TicketDetail.BookId

GROUP BY Book.id
HAVING count(Quantity) >= 3;

SELECT *
FROM v_getBookInfo;

# 2.	View v_getTicketList hiển thị danh sách Ticket gồm:
# Id, TicketDate, Status, CusName, Email, Phone,TotalAmount
# (Trong đó TotalAmount là tổng giá trị tiện phải trả,
# cột Status nếu = 0 thì hiển thị Chưa trả, = 1 Đã trả, = 2 Quá hạn, 3 Đã hủy)
CREATE VIEW v_getTicketList AS
SELECT t.Id,
       t.TicketDate,
       CASE
           WHEN t.Status = 0 THEN 'Chưa trả'
           WHEN t.Status = 1 THEN 'Đã trả'
           WHEN t.Status = 2 THEN 'Quá hạn'
           ELSE 'Đã hủy'
           END                           AS Status,
       c.Name,
       c.Email,
       c.Phone,
       SUM(td.DeposiPrice * td.Quantity) AS TotalAmount
FROM Ticket t
         JOIN Customer c ON t.CustomerID = c.id
         join TicketDetail td on t.id = td.TicketId
GROUP BY t.id, t.TicketDate, t.Status, c.Name, c.Email, c.Phone;

select *
from v_getticketlist;
# Yêu cầu 3 ( Sử dụng lệnh SQL tạo thủ tục Stored Procedure )
# 1.	Thủ tục addBookInfo thực hiện thêm mới Book, khi gọi thủ tục truyền đầy đủ các giá trị của bảng Book ( Trừ cột tự động tăng )
# a.	Thủ tục getTicketByCustomerId hiển thị danh sách đơn hàng của khách hàng theo Id khách hàng gồm: Id, TicketDate, Status, TotalAmount (Trong đó cột Status nếu =0 Chưa trả, = 1  Đã trả, = 2 Quá hạn, 3 đã hủy ), Khi gọi thủ tục truyền vào id cuả khách hàng


#  Tạo thủ tục
DELIMITER //
CREATE PROCEDURE addBookInfo(Name_in varchar(150), Staust_in tinyint, Price_in float, CreatedDate_in date,
                             CategoryID_in int, AuthorId_in int)
begin
    insert into Book(Name, Status, Price, CreatedDate, CategoryId, AuthorId)
    values (Name_in, Staust_in, Price_in, CreatedDate_in, CategoryID_in, AuthorId_in);
end;
//

drop procedure addBookInfo;
call addBookInfo('sach', 1, 900000, '2024/12/12', 4, 3);

DELIMITER //
CREATE PROCEDURE getTicketByCustomerId(CustomerID_in int)
begin
    SELECT t.CustomerId                      AS Id,
           t.TicketDate,
           CASE
               WHEN t.Status = 0 THEN 'Chưa trả'
               WHEN t.Status = 1 THEN 'Đã trả'
               WHEN t.Status = 2 THEN 'Quá hạn'
               ELSE 'Đã hủy'
               END                           AS Status,
           SUM(ti.DeposiPrice * ti.Quantity) AS TotalAmount
    FROM Ticket t
             JOIN Customer c ON t.CustomerID = c.id
             JOIN TicketDetail ti ON t.id = ti.TicketID
    WHERE t.CustomerID = @CustomerId
    GROUP BY t.id, t.TicketDate, t.Status;
end;
//

call getTicketByCustomerId(3);

# 2.	Thủ tục getBookPaginate lấy ra danh sách sản phẩm có phân trang gồm:
# Id, Name, Price, Sale_price, Khi gọi thủ tuc truyền vào limit và page

DELIMITER //
CREATE PROCEDURE getBookPaginate(limit_in INT,
                                 page_in INT)
begin
    WITH book_paginated AS (SELECT id,
                                   name,
                                   Price,
                                   RentCost Sale_price
                            FROM Book
                                     join TicketDetail on Book.id = TicketDetail.BookId
                            ORDER BY id
                            LIMIT limit_in OFFSET page_in
        )
    SELECT * FROM book_paginated;
end;
//
