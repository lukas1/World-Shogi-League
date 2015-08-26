class @EmailSender

    sendEmail: (to, subject, body) ->

        if SENDER_EMAIL?.length == 0
            SENDER_EMAIL = "test@test.com"

        Email.send
            from: SENDER_EMAIL
            to: to
            subject: subject
            text: body
