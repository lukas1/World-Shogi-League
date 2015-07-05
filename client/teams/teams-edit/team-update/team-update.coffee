Template.teamupdate.helpers
    blockASelected: ->
        this.block == "A"
    blockBSelected: ->
        this.block == "B"

Template.teamupdate.events
    "click .cancelEdit": (event, template) ->
        $(event.target).closest('.editLine').remove()
    "click .confirmEdit": (event, template) ->
        name = template.$('.teamNameEdit').val()
        block = template.$('.teamBlockEdit').val()

        return false if not name?.length

        Teams.update this._id, {$set: {name: name, block: block}}
        $(event.target).closest('.editLine').remove()
