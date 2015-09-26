userId = () ->
    Template.instance().data.params._id

userData = () ->
    return Meteor.users.findOne userId()

Template.userProfile.helpers
    userData: userData

    teamData: ->
        Teams.findOne userData().teamId

Template.userProfile.events
    "click #foo": (event, template) ->
