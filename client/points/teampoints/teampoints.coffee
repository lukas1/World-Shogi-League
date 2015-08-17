Template.teampoints.events
    "click .teamNameParent": (event, tpl) ->
        event.stopPropagation()
        Router.go Routes.teamProfile.name, { _id: this._id }
