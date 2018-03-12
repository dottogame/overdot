defmodule AuthEngine.MailEngine.Emails do
  import Bamboo.Email

  def welcome_email(target, nick, code) do
    link = "https://dotto.mcfish.space/verify/" <> target <> "/" <> code

    html = """
    <html>
    <head></head>
    <body>
    <div style="background-color:#fff;margin:0 auto 0 auto;padding:30px 0 30px 0;color:#4f565d;font-size:13px;line-height:20px;font-family:'Helvetica Neue',Arial,sans-serif;text-align:left;">
    <center>
    <table style="width:500px;text-align:center;">
    <tbody>
    <tr>
    <td style="padding:0 0 20px 0;border-bottom:1px solid #e9edee;"><a href="#" style="display:block;margin:0 auto;" target="_blank"><img src="http://104.131.37.118/assets/popsquad_logo.png" width="150" alt="PopSquad logo" style="border:0;"/></a></td>
    </tr>
    <tr>
    <td colspan="2" style="padding:30px 0;">
    <p style="color:#1d2227;line-height:28px;font-size:22px;margin:12px 10px 20px 10px;font-weight:400;">#{
      nick
    }, was it?</p>
    <p style="margin:0 10px 10px 10px;padding:0;">You're almost ready to hop in the game! Please press this shiny, state-of-the-art button, to prove you own this email...</p>
    <p><a style="display:inline-block;text-decoration:none;padding:15px 20px;background-color:#2baaed;border:1px solid #2baaed;border-radius:3px;color:#FFF;font-weight:bold;" target="_blank" href="#{
      link
    }">Shiny "Verify" Button</a></p>
    <p style="padding-top:40px;">...or copy the following link into your URL bar. It's the same as pressing the button, but not as shiny: <a>#{
      link
    }</a></p>
    </td>
    </tr>
    <tr>
    <td colspan="2" style="padding:30px 0 0 0;border-top:1px solid #e9edee;color:#9b9fa5;">Didn't make an account? Aw, that's too bad. Just ignore this email... or make an account! If you have any questions, send us an email at <a style="color:#666d74;text-decoration:none;" href="mailto:support@popsquad.gfruit.info"
    target="_blank">support@popsquad.gfruit.info</a></td>
    </tr>
    </tbody>
    </table>
    </center>
    </div>
    </body>
    </html>
    """

    new_email()
    |> to(target)
    |> from("popsquad@psq.mcfish.space")
    |> subject("Verify Email")
    |> html_body(html)
    |> text_body(
      "Hey #{nick}, your account is almost made! Please enter the appended link into your URL bar to verify your account. If this wasn't you, simply ignore this email. #{
        link
      }"
    )
  end
end
