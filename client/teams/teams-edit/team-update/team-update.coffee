Template.teamupdate.helpers
    blockASelected: ->
        this.block == "A"
    blockBSelected: ->
        this.block == "B"

Template.teamupdate.events
    "click .cancelEdit": (event, template) ->
        $('.editLine').remove()
    "click .confirmEdit": (event, template) ->
        return false if not Meteor.userId()?
        return false if not confirm "Do you really want to update this team?"
        name = template.$('.teamNameEdit').val()
        block = template.$('.teamBlockEdit').val()
        points = parseInt(template.$('.teamPointsEdit').val())

        return false if not name?.length

        Teams.update this._id,
            $set:
                name: name
                block: block
                points: points
        $(event.target).closest('.editLine').remove()


Template.teamupdate.closeAllInstances = ->
    $('.editLine').remove()
