CREATE DATABASE "defaultdb" /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

CREATE TABLE "bookings" (
  "id" int NOT NULL AUTO_INCREMENT,
  "match_id" int NOT NULL,
  "court_id" int NOT NULL,
  "user_id" int NOT NULL,
  "owner_id" int NOT NULL,
  "total_price" decimal(10,2) NOT NULL,
  "status" enum('pending','approved','rejected','payment_pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  "requested_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE KEY "match_id" ("match_id"),
  KEY "court_id" ("court_id"),
  KEY "user_id" ("user_id"),
  KEY "owner_id" ("owner_id"),
  CONSTRAINT "bookings_ibfk_1" FOREIGN KEY ("match_id") REFERENCES "matches" ("id"),
  CONSTRAINT "bookings_ibfk_2" FOREIGN KEY ("court_id") REFERENCES "courts" ("id"),
  CONSTRAINT "bookings_ibfk_3" FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
  CONSTRAINT "bookings_ibfk_4" FOREIGN KEY ("owner_id") REFERENCES "users" ("id")
);

CREATE TABLE "courts" (
  "id" int NOT NULL AUTO_INCREMENT,
  "venue_id" int NOT NULL,
  "sport_id" int NOT NULL,
  "name" varchar(100) NOT NULL,
  "price_per_hour" decimal(10,2) NOT NULL,
  "status" enum('open','closed','maintenance') NOT NULL DEFAULT 'open',
  PRIMARY KEY ("id"),
  KEY "venue_id" ("venue_id"),
  KEY "sport_id" ("sport_id"),
  CONSTRAINT "courts_ibfk_1" FOREIGN KEY ("venue_id") REFERENCES "venues" ("id") ON DELETE CASCADE,
  CONSTRAINT "courts_ibfk_2" FOREIGN KEY ("sport_id") REFERENCES "sports" ("id") ON DELETE CASCADE
);

CREATE TABLE "friendships" (
  "user_one_id" int NOT NULL,
  "user_two_id" int NOT NULL,
  "status" enum('pending','accepted','blocked') NOT NULL DEFAULT 'pending',
  "requested_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_one_id","user_two_id"),
  KEY "user_two_id" ("user_two_id"),
  CONSTRAINT "friendships_ibfk_1" FOREIGN KEY ("user_one_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "friendships_ibfk_2" FOREIGN KEY ("user_two_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "friendships_chk_1" CHECK ((`user_one_id` < `user_two_id`))
);

CREATE TABLE "match_participants" (
  "match_id" int NOT NULL,
  "user_id" int NOT NULL,
  "joined_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("match_id","user_id"),
  KEY "user_id" ("user_id"),
  CONSTRAINT "match_participants_ibfk_1" FOREIGN KEY ("match_id") REFERENCES "matches" ("id") ON DELETE CASCADE,
  CONSTRAINT "match_participants_ibfk_2" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE
);

CREATE TABLE "matches" (
  "id" int NOT NULL AUTO_INCREMENT,
  "creator_id" int NOT NULL,
  "sport_id" int NOT NULL,
  "title" varchar(255) NOT NULL,
  "description" text,
  "skill_level_required" enum('beginner','intermediate','advanced','all') DEFAULT 'all',
  "max_players" int DEFAULT '2',
  "start_time" datetime NOT NULL,
  "end_time" datetime NOT NULL,
  "status" enum('open','full','completed','cancelled') DEFAULT 'open',
  PRIMARY KEY ("id"),
  KEY "creator_id" ("creator_id"),
  KEY "sport_id" ("sport_id"),
  CONSTRAINT "matches_ibfk_1" FOREIGN KEY ("creator_id") REFERENCES "users" ("id"),
  CONSTRAINT "matches_ibfk_2" FOREIGN KEY ("sport_id") REFERENCES "sports" ("id")
);

CREATE TABLE "payments" (
  "id" int NOT NULL AUTO_INCREMENT,
  "booking_id" int NOT NULL,
  "user_id" int NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "payment_method" varchar(50) DEFAULT NULL,
  "transaction_id" varchar(255) DEFAULT NULL,
  "status" enum('pending','success','failed') NOT NULL DEFAULT 'pending',
  "paid_at" timestamp NULL DEFAULT NULL,
  PRIMARY KEY ("id"),
  KEY "booking_id" ("booking_id"),
  KEY "user_id" ("user_id"),
  CONSTRAINT "payments_ibfk_1" FOREIGN KEY ("booking_id") REFERENCES "bookings" ("id"),
  CONSTRAINT "payments_ibfk_2" FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);

CREATE TABLE "reviews" (
  "id" int NOT NULL AUTO_INCREMENT,
  "booking_id" int NOT NULL,
  "user_id" int NOT NULL,
  "court_id" int NOT NULL,
  "rating" int NOT NULL,
  "comment" text,
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE KEY "booking_id" ("booking_id"),
  KEY "user_id" ("user_id"),
  KEY "court_id" ("court_id"),
  CONSTRAINT "reviews_ibfk_1" FOREIGN KEY ("booking_id") REFERENCES "bookings" ("id"),
  CONSTRAINT "reviews_ibfk_2" FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
  CONSTRAINT "reviews_ibfk_3" FOREIGN KEY ("court_id") REFERENCES "courts" ("id"),
  CONSTRAINT "reviews_chk_1" CHECK (((`rating` >= 1) and (`rating` <= 5)))
);

CREATE TABLE "sports" (
  "id" int NOT NULL AUTO_INCREMENT,
  "name" varchar(100) NOT NULL,
  PRIMARY KEY ("id"),
  UNIQUE KEY "name" ("name")
);

CREATE TABLE "user_profiles" (
  "user_id" int NOT NULL,
  "display_name" varchar(100) NOT NULL,
  "first_name" varchar(50) DEFAULT NULL,
  "last_name" varchar(50) DEFAULT NULL,
  "phone_number" varchar(20) DEFAULT NULL,
  "date_of_birth" date DEFAULT NULL,
  "gender" enum('male','female','other') DEFAULT NULL,
  "bio" text,
  "avatar_url" varchar(255) DEFAULT NULL,
  "location_address" text,
  "latitude" decimal(10,8) DEFAULT NULL,
  "longitude" decimal(11,8) DEFAULT NULL,
  PRIMARY KEY ("user_id"),
  UNIQUE KEY "phone_number" ("phone_number"),
  CONSTRAINT "user_profiles_ibfk_1" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE
);

CREATE TABLE "user_sports" (
  "user_id" int NOT NULL,
  "sport_id" int NOT NULL,
  "skill_level" enum('beginner','intermediate','advanced','pro') DEFAULT 'beginner',
  PRIMARY KEY ("user_id","sport_id"),
  KEY "sport_id" ("sport_id"),
  CONSTRAINT "user_sports_ibfk_1" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "user_sports_ibfk_2" FOREIGN KEY ("sport_id") REFERENCES "sports" ("id") ON DELETE CASCADE
);

CREATE TABLE "users" (
  "id" int NOT NULL AUTO_INCREMENT,
  "email" varchar(100) NOT NULL,
  "password_hash" varchar(255) NOT NULL,
  "role" enum('player','owner') NOT NULL DEFAULT 'player',
  "created_at" timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  UNIQUE KEY "email" ("email")
);

CREATE TABLE "venues" (
  "id" int NOT NULL AUTO_INCREMENT,
  "owner_id" int NOT NULL,
  "name" varchar(255) NOT NULL,
  "address" text NOT NULL,
  "description" text,
  "latitude" decimal(10,8) DEFAULT NULL,
  "longitude" decimal(11,8) DEFAULT NULL,
  "open_time" time DEFAULT NULL,
  "close_time" time DEFAULT NULL,
  PRIMARY KEY ("id"),
  KEY "owner_id" ("owner_id"),
  CONSTRAINT "venues_ibfk_1" FOREIGN KEY ("owner_id") REFERENCES "users" ("id") ON DELETE CASCADE
);