Template.matches.helpers({
    matches: function() {
        return Matches.find({}, {sort: {createdAt: -1}});
    },
});

Template.matches.events({
    "submit .new-match-form": function (event) {
      // This function is called when the new task form is submitted
      var text = event.target.text.value;

      Matches.insert({
        // TODO:
      });

      // Clear form
      event.target.text.value = "";

      // Prevent default form submit
      return false;
    }
});
