Template.teamupdate.helpers
    classes: ->
        return CLASSES
    classSelected: (classToCheck)->
        Template.instance().data.class == classToCheck

Template.teamupdate.events
    "click .cancelEdit": (event, template) ->
        $('.editLine').remove()
    "click .confirmEdit": (event, template) ->
        return false if not isAdmin()
        return false if not confirm "Do you really want to update this team?"
        name = template.$('.teamNameEdit').val()
        tclass = template.$('.teamClassEdit').val()
        points = parseInt(template.$('.teamPointsEdit').val())

        return false if not name?.length

        updateData =
            $set:
                name: name
                class: tclass
                points: points

        Meteor.call "updateTeam", this._id, updateData, (error, result) ->
            if error
                alert "Failed to update team"
                return

            $(event.target).closest('.editLine').remove()

Template.teamupdate.closeAllInstances = ->
    $('.editLine').remove()
