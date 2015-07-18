dateTimeFormat = 'DD/MM/YYYY HH:mm'

showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#errorMessageContainer').get(0)
    return false

# throws
boardDataForPlayerId = (playerId) ->
    matchId = getMatchIdForPlayer playerId
    board = Boards.findOne
        playerId: Meteor.userId()
        matchId: matchId

    return board

Template.scheduleMatch.helpers
    boardData: ->
        try
            return boardDataForPlayerId Meteor.userId()
        catch error
            return null
    opponentBoardData: ->
        try
            matchId = getMatchIdForPlayer Meteor.userId()
            board = Boards.findOne
                playerId: { $not: Meteor.userId() }
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
    this.$('#dateTimeStartPickerText, #dateTimeEndPickerText').datetimepicker
        useCurrent: false
        allowInputToggle: true
        sideBySide: true
        showClear: true
        format: dateTimeFormat

    this.$('#dateTimeStartPickerText').on "dp.change", (e)->
        $('#dateTimeEndPickerText').data("DateTimePicker").minDate(e.date)

    this.$('#dateTimeEndPickerText').on "dp.change", (e)->
        $('#dateTimeStartPickerText').data("DateTimePicker").maxDate(e.date)

Template.scheduleMatch.events
    "submit #addToSchedule": (e, tpl) ->
        e.preventDefault()

        errorTitle = "Could not add dates to schedule!"

        startDate = $('#dateTimeStartPickerText').find('input').val()
        endDate = $('#dateTimeEndPickerText').find('input').val()
        startDateObj = moment(startDate, dateTimeFormat).toDate()
        endDateObj = moment(endDate, dateTimeFormat).toDate()

        if not startDate?.length
            return showError errorTitle, "Select starting date and time"
        if not endDate?.length
            return showError errorTitle, "Select ending date and time"

        try
            board = boardDataForPlayerId Meteor.userId()

            Meteor.call "addToSchedule", board._id, startDateObj, endDateObj,
            (error, result) ->
                if error
                    return showError errorTitle, error.reason

                # Adding to schedule successful, clear inputs
                $('#dateTimeStartPickerText').find('input').val('')
                $('#dateTimeEndPickerText').find('input').val('')
                $('#dateTimeStartPickerText')
                    .data("DateTimePicker").maxDate(false)
                $('#dateTimeEndPickerText')
                    .data("DateTimePicker").minDate(false)

        catch error
            return showError errorTitle, error.reason

        return false
