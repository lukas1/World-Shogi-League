dateTimeFormat = 'DD/MM/YYYY HH:mm'

showError = (title, message, top = false) ->
    errorContainer = $('#errorMessageContainer').get(0)
    errorContainer = $('#errorMessageRemoveContainer').get(0) if top
    Template.errorTemplate.showError title, message,
    errorContainer
    return false

opponentBoardData = () ->
    try
        myBoard = boardDataForPlayerAndMatch Meteor.userId(),
        Session.get 'selectedMatch'

        return board = Boards.findOne
            board: myBoard.board
            playerId: { $ne: Meteor.userId() }
            teamId: { $ne: myBoard.teamId }
            matchId: myBoard.matchId
    catch error
        return null

opponentData = () ->
    try
        board = opponentBoardData()
        user = Meteor.users.findOne board.playerId
        user["email"] = user.emails[0].address
        return user
    catch error
        return null

Template.scheduleMatch.helpers
    participatingRounds: ->
        return participatingRoundsForPlayerId Meteor.userId()
    selectedMatch: ->
        Session.get 'selectedMatch'
    boardData: ->
        try
            board = boardDataForPlayerAndMatch Meteor.userId(),
            Session.get 'selectedMatch'
            board["addScheduleClass"] = 'hidden' if board.matchDate?
            return board
        catch error
            return null
    opponentBoardData: opponentBoardData
    opponentData: opponentData
    opponentTeamData: ->
        match = Matches.findOne Session.get 'selectedMatch'
        return null if not match?

        ot = otherTeam(Meteor.user().profile.teamId,
            [ match.teamAId, match.teamBId]
        )
        Teams.findOne ot


Template.scheduleMatch.onRendered ->
    Session.set 'selectedMatch', ''

Template.scheduleMatch.events
    "change #roundSelect": (e, tpl) ->
        Session.set 'selectedMatch', $(e.target).val()
        # A hack to initialize date pickers
        setTimeout((() ->
            $('#dateTimeStartPickerText, #dateTimeEndPickerText').datetimepicker
                useCurrent: false
                allowInputToggle: true
                sideBySide: true
                showClear: true
                format: dateTimeFormat
                minDate: new Date()
                defaultDate: new Date()

            $('#dateTimeStartPickerText').on "dp.change", (e)->
                $('#dateTimeEndPickerText')
                    .data("DateTimePicker")
                    .minDate(e.date)

            $('#dateTimeEndPickerText').on "dp.change", (e)->
                $('#dateTimeStartPickerText')
                    .data("DateTimePicker")
                    .maxDate(e.date)
            ), 100
        )
    "submit #addToSchedule": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

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
            board = boardDataForPlayerAndMatch Meteor.userId(),
            Session.get 'selectedMatch'

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
    "click .cancelSchedule": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

        return false if not confirm "Do you really want to remove this date
        from your schedule?"

        errorTitle = "Could not remove date from schedule!"
        try
            board = boardDataForPlayerAndMatch Meteor.userId(),
            Session.get 'selectedMatch'
            scheduleId = $(e.target).attr('id').replace('cancelSchedule', '')

            Meteor.call "removeFromSchedule", board._id, scheduleId,
            (error, result) ->
                if error
                    return showError errorTitle, error.reason, true
        catch error
            return showError errorTitle, error.reason, true

        return false
