
/* one or two writers are updating their current status here */
CREATE TABLE SYNC
(
 sourceid          INT PRIMARY KEY,
 block_num         BIGINT NOT NULL,
 block_time        DATETIME NOT NULL,
 irreversible      BIGINT NOT NULL,
 is_master         SMALLINT NOT NULL,
 last_updated      DATETIME NOT NULL
) ENGINE=InnoDB;

INSERT INTO SYNC (sourceid, block_num, block_time, irreversible, is_master, last_updated) values (1,0, '2000-01-01',0, 1, '2000-01-01');

/*
   parent table for transactions.
   "seq"  is a unique sequence number supplied by the blockchain.
   It may be reassigned to a different transaction after a microfork.
*/ 
CREATE TABLE TRANSACTIONS
(
 seq            BIGINT UNSIGNED PRIMARY KEY,
 block_num      BIGINT NOT NULL,
 block_time     DATETIME NOT NULL,
 trx_id         VARCHAR(64) NOT NULL,
 trace          MEDIUMBLOB NOT NULL
)  ENGINE=InnoDB;

CREATE INDEX TRANSACTIONS_I01 ON TRANSACTIONS (block_num);
CREATE INDEX TRANSACTIONS_I02 ON TRANSACTIONS (block_time);
CREATE INDEX TRANSACTIONS_I03 ON TRANSACTIONS (trx_id(8));


/* all receipt recipients for each transaction */
CREATE TABLE RECEIPTS
(
 seq            BIGINT UNSIGNED NOT NULL,
 block_num      BIGINT NOT NULL,
 block_time     DATETIME NOT NULL,
 account_name   VARCHAR(13) NOT NULL,
 PRIMARY KEY (seq, account_name)
)  ENGINE=InnoDB;

CREATE INDEX RECEIPTS_I01 ON RECEIPTS (block_num);
CREATE INDEX RECEIPTS_I02 ON RECEIPTS (account_name, seq);
CREATE INDEX RECEIPTS_I03 ON RECEIPTS (account_name, block_num);
CREATE INDEX RECEIPTS_I04 ON RECEIPTS (block_time);

/* smart contracts and actions in each transaction */
CREATE TABLE ACTIONS
(
 seq            BIGINT UNSIGNED NOT NULL,
 block_num      BIGINT NOT NULL,
 block_time     DATETIME NOT NULL,
 contract       VARCHAR(13) NOT NULL,
 action         VARCHAR(13) NOT NULL,
 PRIMARY KEY (seq, contract, action) 
)  ENGINE=InnoDB;

CREATE INDEX ACTIONS_I01 ON ACTIONS (block_num);
CREATE INDEX ACTIONS_I02 ON ACTIONS (contract, action, seq);
CREATE INDEX ACTIONS_I03 ON ACTIONS (contract, action, block_num);
CREATE INDEX ACTIONS_I04 ON ACTIONS (contract, block_num);
CREATE INDEX ACTIONS_I05 ON ACTIONS (block_time);


/* this table is used internally for dual-writer setup. Not for user access */
CREATE TABLE BKP_TRACES
(
 seq            BIGINT UNSIGNED PRIMARY KEY,
 block_num      BIGINT NOT NULL,
 block_time     DATETIME NOT NULL,
 trx_id         VARCHAR(64) NOT NULL,
 trace          MEDIUMBLOB NOT NULL
)  ENGINE=InnoDB;

CREATE INDEX BKP_TRACES_I01 ON BKP_TRACES (block_num);
