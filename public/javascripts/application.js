// Load the application once the DOM is ready, using `jQuery.ready`:
$(function(){
	$("#message").autoGrow();
	
	//Message model
  window.Message = Backbone.Model.extend({
	 defaults: function() {
			var date = new Date();
	      return {
	        date_time: $D(date).strftime("%Y-%m-%dT%H-%M-%S"),
	      };
	    },
  });

  // Todo Collection
  // ---------------

  // The collection of todos is backed by *localStorage* instead of a remote
  // server.
  window.MessageList = Backbone.Collection.extend({

    // Reference to this collection's model.
    model: Message,
		url: '/messages',
  });

 	window.Messages = new MessageList;

  // The DOM element for a message item...
  window.MessageView = Backbone.View.extend({
    //... is a list tag.
    tagName:  "li",

    // Cache the template function for a single item.
    template: _.template($('#message-template').html()),

    initialize: function() {
      this.model.bind('change', this.render, this);
 		},
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      this.setText();
      return this;
    },

    // To avoid XSS (not that it would be harmful in this particular app),
    // we use `jQuery.text` to set the contents of the todo item.
    setText: function() {
      this.$('.message-author').text(this.model.get('author'));
      this.$('.message-message').html(this.model.get('message').replace("\n","<br />") );
      this.$('.message-date_time').text(this.model.get('date_time'));
			if(this.model.get('location') && this.model.get('location')['lat'] && this.model.get('location')['lon']) {
	      this.$('.message-geo .lat').text(this.model.get('location')['lat']);
	      this.$('.message-geo .lon').text(this.model.get('location')['lon']);
			}	
    },

  });
	var test = new MessageList;

	window.SearchView = Backbone.View.extend({
		el: $("#searchview"),
		events: {
	    "click #search": "searchMessages",
	    "click #send":   "createMessage",
		},
		
		initialize: function() {
	  	this.input    = this.$("#new-message");

			console.log("initialize");
	    Messages.bind('add',   this.addOne, this);
	    Messages.bind('reset', this.addAll, this);
	
	  },
	
		addOne: function(message) {
			var view = new MessageView({model: message});
			$("#output").append(view.render().el);
		},
		addAll: function() {
			Messages.each(this.addOne);
			render_geo_names();
		},
		clearView: function() {
			$("#output").html('');
		},
    createMessage: function() {
			var message = $('#message').val();
			if (!message) return;
			var geo_lat = $('#geo_lat').val();
			var geo_lon = $('#geo_lon').val();
			Messages.create({message: message, location:{lat: geo_lat, lon: geo_lon}});
			$('#message').val('');
    },		
    searchMessages: function() {
			var message = $('#message').val();
			this.clearView();
			Messages.fetch({data:{message: message}});
    },		
	
	});
	
	window.Search = new SearchView;
});
