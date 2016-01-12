Template.classPoints.helpers
    blanksToAdd: () ->
        blanks = []
        i = 0

        while i < Template.instance().blanksToAdd.get()
            blanks.push '0'
            i++
        return blanks
    teams: () ->
        teams = Teams.find(
            { class: Template.instance().data.class }
        ).map (document, index, cursor) ->
            document['matchPoints'] = matchPointsForTeam document._id
            return document

        teams.sort (a,b) ->
            compare = a.matchPoints - b.matchPoints
            if compare == 0
                compare = a.points - b.points

            if compare == 0
                if a.name > b.name
                    compare = -1
                else if a.name < b.name
                    compare = 1

            return -compare

Template.classPoints.created = () ->
    tpl = Template.instance()
    tpl.blanksToAdd = new ReactiveVar(0)
    Meteor.call "countOfTeamsInBiggestClass", (error, result) ->
        return if error
        teams = Teams.find(
            { class: tpl.data.class }
        ).count()

        if teams < result
            tpl.blanksToAdd.set(result - teams)
