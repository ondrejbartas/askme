/** 
 * Overwrites the original Backbone.sync with a helper function, that decides 
 * whether a model should use the remote storage system, or a local storage. 
 * @param {String} method The crud method to be performed. 
 * @param {Backbone.Model} The model that triggered this sync. 
 * @param {Object} options The options to be handed on to the $.ajax method. 
 * @function 
 */ 
Backbone.sync = function(method, model, options) { 
    // In case there is both a local storage and a url defined, check the 
    // options hash. 
    // Fallback to remote storage 
   if((model.localStorage || (model.collection && model.collection.localStorage)) && 
      (model.urlRoot || (model.collection && model.collection.url))){ 
      if(options.location === "local"){ 
         LocalStorage.sync(method, model, options); 
      } 
      else{ 
         RemoteStorage.sync(method, model, options); 
      } 
   } 
   // If there is just a local storage defined, save to local storage 
   else if(model.localStorage || (model.collection && model.collection.localStorage)){ 
      LocalStorage.sync(method, model, options); 
   } 
   // Otherwise trust on a remote storage 
   else{ 
      RemoteStorage.sync(method, model, options); 
   } 
};