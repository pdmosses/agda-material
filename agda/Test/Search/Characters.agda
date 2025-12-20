module Test.Search.Characters where

-- ASCII:
-- ! " # $ % & ' ( ) * + , - . / 0 9 : ; < = > ? @ A Z [ \ ] ^ _ ` a z { | } ~

-- Searchable ASCII characters:
-- ! $ % & ( ) , . / 0 9 ? @ = [ ] A Z _ ` a z { | }

-- Non-searchable ASCII characters:
-- " ' * + - : < > \ ^ ~

-- Corrupted results:
-- # ;