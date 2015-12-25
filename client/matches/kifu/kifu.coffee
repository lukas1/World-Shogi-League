getKifuId = ()->
    Template.instance().data.params._id

getKifu = ()->
    kifuData = Kifu.findOne getKifuId()
    return kifuData.kifu


Template.kifu.rendered = () ->
    kifu = getKifu()
    $('#kifuframe').load () ->
        Meteor.call "decodeKifu", kifu, (error, result) ->
            $("#kifuframe").contents().find("#kifuSource").html result
