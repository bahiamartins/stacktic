// 
// DataStore abstract class
//
// A DataStore retreives objects that will be used by other components
// to build the site.
// 
// First of all.. It is not mandatory for a DataStore to follow this specification. 
// It's always possible to use ie. a database driver direcly. But it's raccomended to
// implement that small set of methods to create interchangeable DataStores with 
// a consistent interface.
// 
// DataStores are designed to support mainly File Systems, rest APIs and Document-oriented
// databases.
// So we assume data to have a tree structure and to be referenceable through paths.
// 
// Also by default we assume that a path will reference a collection of objects.

/* abstract */ function DataStore() {
};

// Retrieves objects referenced by `path` and calls cb(err, data) where `data` are the objects.
// `err` is the error message in case an error occurs or `null` otherwise.
// 
DataStore.prototype.get    = /* abstract */ function(path, cb) {
  throw('NotImplemented');
};

// Calls cb on first get result
DataStore.prototype.first  = function(path, cb) {
  this.get(path, function(err, data){
    cb(err, data.length ? data[0] : null);
  });
};

// Calls cb iterating through get results, it throws an error in case of failure.
DataStore.prototype.each   = function(path, cb) {
  this.get(path, function(err, data){
    if (err) { throw(err); };
    data.forEach(cb);
  });
};


module.exports = DataStore;