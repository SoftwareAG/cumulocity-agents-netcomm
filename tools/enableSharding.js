//example command to run:
//mongo -u init-root -p <password> --authenticationDatabase admin admin --eval 'var dbs = ["anotherdatabase"]; var dropDatbase = true; ' enableSharding.js

//config//
if(typeof enableSharding == 'undefined'){
  var enableSharding = true
};
if(typeof dropDatabase == 'undefined'){
  var dropDatabase = false
};
if(typeof baseNumInitialChunks == 'undefined'){
  var baseNumInitialChunks = 8192
};
if(typeof numberOfShards == 'undefined'){
  var numberOfShards = 3
};
if(typeof numInitialChunks == 'undefined'){
  var numInitialChunks = baseNumInitialChunks * numberOfShards
};

if(typeof dbs == 'undefined'){
  var dbs = [
    "database1",
    "database2",
    "database3",
    "databaseN",
  ]
};
//////////
if(typeof debug == 'undefined'){
  debug = false
};
//////////

var db = db.getSiblingDB("admin");

var commonCols = [
  { "name" : "alarms",                 "key" : "source"   },
  { "name" : "audits",                 "key" : "source"   },
  { "name" : "available_authorities",  "key" : "_id"      },
  { "name" : "bulk_operations",        "key" : "_id"      },
  { "name" : "cep_modules",            "key" : "_id"      },
  { "name" : "cmdata",                 "key" : "_id"      },
  { "name" : "cmdata.chunks",          "key" : "files_id" },
  { "name" : "cmdata.files",           "key" : "_id"      },
  { "name" : "configuration",          "key" : "_id"      },
  { "name" : "events",                 "key" : "source"   },
  { "name" : "events_attachment",      "key" : "source"   },
  { "name" : "events_attachment_part", "key" : "source"   },
  { "name" : "inventory_roles",        "key" : "_id"      },
  { "name" : "operations",             "key" : "deviceId" },
  { "name" : "options",                "key" : "_id"      },
  { "name" : "pmdata",                 "key" : "source"   },
  { "name" : "retentions",             "key" : "_id"      },
  { "name" : "sequences",              "key" : "_id"      },
  { "name" : "user_groups",            "key" : "_id"      },
  { "name" : "users",                  "key" : "_id"      },
];

var managementOnlyCols = [
  { "name" : "applications",           "key" : "_id"      },
  { "name" : "tenants",                "key" : "_id"      },
  { "name" : "tenant_db_statuses",     "key" : "_id"      },
  { "name" : "timed_locks",            "key" : "_id"      },
];

var errorCount = 0;

function shardMyCol(database,col,keyname,nIC){
  var shardkey = {};
  shardkey[keyname] = "hashed";
  var adminDb = db.getSiblingDB("admin");
  if(debug){ print("database:" + database + "\ncol:" + col + "\nshardkey:" + shardkey + "\nnIC:" + nIC); };
  if(debug){ print("adminDb.runCommand( { shardcollection : \"" + database + "." + col + "\", key : " + JSON.stringify(shardkey) + ", unique : false, numInitialChunks : " + nIC + "} );"); };
  print("Sharding collection => " + col);
  var firstAttempt = adminDb.runCommand( {
    shardcollection : database + "." + col,
    key : shardkey,
    unique : false,
    numInitialChunks : nIC
  } );
  if(debug){ print(JSON.stringify(firstAttempt)) };
  if(firstAttempt.ok != 1 && firstAttempt.errmsg == "numInitialChunks is not supported when the collection is not empty."){
    print(" ├ WARNING: First attempt failed with this message:\n ├ " + firstAttempt.errmsg);
    print(" ├ Trying without using 'numInitialChunks'");
    var secondAttempt = adminDb.runCommand( {
      shardcollection : database + "." + col,
      key : shardkey,
      unique : false
    } );
    if(debug){ print(JSON.stringify(secondAttempt)) };
    if(secondAttempt.ok == 1){
      print(" └ Collection has been successfully sharded on second attempt");
    } else {
      errorCount++;
      print(" ├ ERROR: something went wrong\n └ " + secondAttempt.errmsg);
      print(secondAttempt.errmsg);
    };
  } else if(firstAttempt.ok != 1){
    errorCount++;
    print(" ├ ERROR: something went wrong\n └ " + firstAttempt.errmsg);
  } else {
    print(" └ Collection has been successfully sharded");
  };
};

dbs.forEach(function(database) {
  print("DATABASE => " + database);

  if(dropDatabase) {
    print("Dropping database => " + database);
    usedDb = db.getSiblingDB(database);
    usedDb.runCommand( { dropDatabase: 1 } );
  };

  if(enableSharding) {
    print("Sharding database => " + database);
    sh.enableSharding(database);

    if(database == "management") {
      print("Special management database collections...");
      managementOnlyCols.forEach(function(col){
        shardMyCol(database,col.name,col.key,numInitialChunks);
      });
    };

    commonCols.forEach(function(col){
      shardMyCol(database,col.name,col.key,numInitialChunks);
    });

  };
  print()
});

if(errorCount > 255){ errorCount=255 };

quit(errorCount);

