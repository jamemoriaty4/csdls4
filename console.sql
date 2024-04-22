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
    Email      varchar(150) not null unique check ( Email like '%@gmail.com' or '%@facebook.com 'or
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
    DECLARE book_price DECIMAL(10,2);
    SELECT Price INTO book_price
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

select BOOk.id, book.Name, 	Price, book.Status, C.Name, A.Name , CreatedDate
from Book join Category C on Book.Status = C.Status join Author A on Book.Name = A.Name
order by Price desc ;

# 2.	Lấy ra danh sách Category gồm:
# Id, Name, TotalProduct, Status (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )

select Category.Id, Category.Name, b.Price,
       CASE WHEN Category.Status = 0 THEN 'Ẩn' ELSE 'Hiển thị' END AS Status
from Category join Book B on Category.Status = B.Status;

#3	Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address,CreatedDate,
# Gender, BirthDay, Age (Age là cột suy ra từ BirthDay, Gender nếu = 0 là Nam, 1 là Nữ,2 là khác )

select *,case when Customer.Gender = 0 THEN 'Nữ' ELSE 'Nam' END AS Gender, year(curdate())-year(Customer.BirthDay) Tuoi
from Customer;

# 4.	Truy vấn xóa Author chưa có sách nào
DELETE FROM Author a
WHERE NOT EXISTS (
    SELECT 1 FROM Book b
    WHERE b.AuthorId = a.Id
);

# 5.	Cập nhật Cột ToalBook trong bảng Auhor = Tổng số Book của mỗi Author theo Id của Author
UPDATE Author a
SET TotalBook = (
    SELECT COUNT(*)
    FROM Book b
    WHERE b.AuthorId = a.Id
)
WHERE a.Id IN (
    SELECT AuthorId
    FROM Book
    GROUP BY AuthorId
);

create procedure

