var _ = require('lodash');

function Collection(object) {
  if (_.isNull(object)) {
    this.items = [];  
  } else {
    this.items = _.isArray(object) ? object : [object];  
  }  
}

Collection.create = function(object) {
  return new Collection(object);
};

Collection.prototype.all = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.all.apply(_, args));
};

Collection.prototype.any = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.any.apply(_, args));
};

Collection.prototype.at = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.at.apply(_, args));
};

Collection.prototype.collect = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.collect.apply(_, args));
};

Collection.prototype.contains = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.contains.apply(_, args));
};

Collection.prototype.countBy = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.countBy.apply(_, args));
};

Collection.prototype.detect = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.detect.apply(_, args));
};

Collection.prototype.each = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.each.apply(_, args));
};

Collection.prototype.eachRight = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.eachRight.apply(_, args));
};

Collection.prototype.every = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.every.apply(_, args));
};

Collection.prototype.filter = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.filter.apply(_, args));
};

Collection.prototype.find = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.find.apply(_, args));
};

Collection.prototype.findLast = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.findLast.apply(_, args));
};

Collection.prototype.foldl = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.foldl.apply(_, args));
};

Collection.prototype.foldr = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.foldr.apply(_, args));
};

Collection.prototype.forEach = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.forEach.apply(_, args));
};

Collection.prototype.forEachRight = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.forEachRight.apply(_, args));
};

Collection.prototype.groupBy = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.groupBy.apply(_, args));
};

Collection.prototype.include = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.include.apply(_, args));
};

Collection.prototype.indexBy = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.indexBy.apply(_, args));
};

Collection.prototype.inject = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.inject.apply(_, args));
};

Collection.prototype.invoke = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.invoke.apply(_, args));
};

Collection.prototype.map = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.map.apply(_, args));
};

Collection.prototype.max = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.max.apply(_, args));
};

Collection.prototype.min = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.min.apply(_, args));
};

Collection.prototype.pluck = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.pluck.apply(_, args));
};

Collection.prototype.reduce = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.reduce.apply(_, args));
};

Collection.prototype.reduceRight = function() {
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.reduceRight.apply(_, args));
};

Collection.prototype.reject = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.reject.apply(_, args));
};

Collection.prototype.sample = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.sample.apply(_, args));
};

Collection.prototype.select = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.select.apply(_, args));
};

Collection.prototype.shuffle = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.shuffle.apply(_, args));
};

Collection.prototype.size = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.size.apply(_, args));
};

Collection.prototype.some = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.some.apply(_, args));
};

Collection.prototype.sortBy = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.sortBy.apply(_, args));
};

Collection.prototype.toArray = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.toArray.apply(_, args));
};

Collection.prototype.where = function(){
  var args = _.toArray(arguments);
  args.unshift(this.items);
  return Collection.create(_.where.apply(_, args));
};

Collection.prototype.paginate = function(number) {
  var slices = (function(array, number){
    var index = -number, slices = [];
    if (number < 1) { 
      return array; 
    }
    while ((index += number) < array.length) {
        var s = array.slice(index, index + number);
        slices.push(s);
    }
    return slices;
  })(this.items, number);

  var i = 1,
      pages = _.map(slices, function(slice){ return {page: i++, items: slice}; });
  
  return Collection.create(pages);
};

Collection.prototype.offset = function(number) {
  return Collection.create(this.items.slice(number));
};

Collection.prototype.limit = function(number) {
  return Collection.create(this.items.slice(0, number));
};

Collection.prototype.slice = function(a, b) {
  return Collection.create(this.items.slice(a, b));
};

Collection.prototype.toArray = function(opts) {
  return (opts && opts.clone) ? _.clone(this.items) : this.items;
};

module.exports = Collection.create;