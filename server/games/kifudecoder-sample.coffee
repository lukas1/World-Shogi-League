###

This is a sample file for decoding kifu file.
This code just returns back the data, so this is not good for the project.

Basically there is no reliable javascript implementation of base64decode that
would return correct UTF-8 encoded data, which is a shame, so one needs to
make a use of remote base 64 decode service, that can decode correctly
(PHP base64decode method can do that just fine)

Meteor.methods
    decodeKifu: (kifu) ->
        fut = new Future();
        kifuStripped = kifu.replace('data:;base64,', '');
        uploadData =
            params:
                data: kifuStripped

        HTTP.call "POST", "http://base64decode.com/",
        uploadData, (error, result) ->
            fut.return result?.content

        return kifu

###
