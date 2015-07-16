Template.scheduleMatch.helpers
    boardData: ->
        try
            matchId = getMatchIdForPlayer Meteor.userId()
            board = Boards.findOne
                playerId: Meteor.userId()
                matchId: matchId

            return board
        catch error
            return null

    matchData: ->
        try
            matchId = getMatchIdForPlayer Meteor.userId()
            matchData = Matches.findOne matchId
            return matchData
        catch error
            return null
    opponentData: ->
        try
            matchId = getMatchIdForPlayer Meteor.userId()
            board = Boards.findOne
                playerId: { $not: Meteor.userId() }
                matchId: matchId

            return Meteor.users.findOne board.playerId
        catch error
            return null

Template.scheduleMatch.onRendered ->
    this.$('#dateTimePickerText').datetimepicker()

Template.scheduleMatch.events
    "submit #addToSchedule": (e, tpl) ->
        e.preventDefault()
        return false
