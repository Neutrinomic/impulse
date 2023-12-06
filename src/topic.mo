import Blob "mo:base/Blob";
import BTree "mo:stableheapbtreemap/BTree";
import Nat64 "mo:base/Nat64";
import Int32 "mo:base/Int32";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Prim "mo:⛔";
import Vector "mo:vector";
import RXMDB "mo:rxmodb";
import O "mo:rxmo";
import PK "mo:rxmodb/primarykey";
import IDX "mo:rxmodb/index"; 

module {

// Document Type
public type Doc = {
    id: Nat64;
    createdAt: Nat32;
    updatedAt: Nat32;
    author: Principal;
    title: Text;
    body: Text;
    meta: Text;
    tags: [Nat32];
    deleted: Bool;
};

public type CreatedAtKey = Nat64;
public type UpdateAtKey = Nat64;
public type ScoreKey = Nat64;
public type PKKey = Nat64;

public type Init = { // All stable
    db : RXMDB.RXMDB<Doc>;
    pk : PK.Init<Nat64>;
    createdAt : IDX.Init<CreatedAtKey>;
    updatedAt : IDX.Init<UpdateAtKey>;
};

public func init() : Init {
    return {
    db = RXMDB.init<Doc>();
    pk = PK.init<PKKey>(?32);
    createdAt = IDX.init<CreatedAtKey>(?32);
    updatedAt = IDX.init<UpdateAtKey>(?32);
    };
};

public func updatedAt_key(idx:Nat, h : Doc) : ?UpdateAtKey = ?((Nat64.fromNat(Nat32.toNat(h.updatedAt)) << 32) | Nat64.fromNat(idx));
public func createdAt_key(idx:Nat, h : Doc) : ?CreatedAtKey = ?((Nat64.fromNat(Nat32.toNat(h.createdAt)) << 32) | Nat64.fromNat(idx));



public func pk_key(h : Doc) : PKKey = h.id;

public type Use = {
    db : RXMDB.Use<Doc>;
    pk : PK.Use<PKKey, Doc>;
    createdAt : IDX.Use<CreatedAtKey, Doc>;
    updatedAt : IDX.Use<UpdateAtKey, Doc>;
};

public func use(init : Init) : Use {
    let obs = RXMDB.init_obs<Doc>(); // Observables for attachments

    // PK
    let pk_config : PK.Config<PKKey, Doc> = {
        db=init.db;
        obs;
        store=init.pk;
        compare=Nat64.compare;
        key=pk_key;
        regenerate=#no;
        };
    PK.Subscribe<PKKey, Doc>(pk_config); 


    // Index - createdAt
    let createdAt_config : IDX.Config<UpdateAtKey, Doc> = {
        db=init.db;
        obs;
        store=init.createdAt;
        compare=Nat64.compare;
        key=createdAt_key;
        regenerate=#no;
        keep=#all;
        };
    IDX.Subscribe(createdAt_config);

    // Index - updatedAt
    let updatedAt_config : IDX.Config<UpdateAtKey, Doc> = {
        db=init.db;
        obs;
        store=init.updatedAt;
        compare=Nat64.compare;
        key=updatedAt_key;
        regenerate=#no;
        keep=#all;
        };
    IDX.Subscribe(updatedAt_config);


    return {
        db = RXMDB.Use<Doc>(init.db, obs);
        pk = PK.Use(pk_config);
        createdAt = IDX.Use(createdAt_config);
        updatedAt = IDX.Use(updatedAt_config);
    }

}


}