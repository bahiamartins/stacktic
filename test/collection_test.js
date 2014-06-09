var collection = require('../lib/collection');

describe('Collection', function(){

  describe('#where', function(){
    it('should return filtered collection', function(){
      collection([{ a: 1 }, { a: 2 }]).where({a: 2}).toArray()
      .should.containEql({a: 2}).and.have.lengthOf(1);
      
    });
  });

  describe('#paginate', function(){
    it('should paginate', function(){
      collection([1,2,3,4,5,6,7,8,9,10]).paginate(3).toArray()
      .should.eql([{page: 1, items: [1,2,3]}, {page: 2, items: [4,5,6]}, {page: 3, items: [7,8,9]}, {page: 4, items: [10]}]);
    });
  });


});
