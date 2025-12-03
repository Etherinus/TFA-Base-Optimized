TFA = TFA or {}

local langstrings = {
    en = {
        nag_1 = "Dear ",
        nag_2 = ", please take a moment to join TFA Mod News. We'd be honored to have you as the ",
        nag_3 = "th member. As soon as you join, you'll stop seeing this message. This repeats up to 5 times; this is #",
        thank_1 = "Thank you, ",
        thank_2 = ", for joining TFA Mod News! You are member #"
    },
    fr = {
        nag_1 = "Chère ",
        nag_2 = ", S'il vous plaît prendre un moment pour rejoindre TFA Mod Nouvelles. Nous serions honorés de vous avoir comme ",
        nag_3 = "ème membre. Dès que vous vous inscrivez, vous arrêtez de voir ce message. Maximum 5 fois; c'est #",
        thank_1 = "Merci, ",
        thank_2 = ", pour rejoindre TFA Mod Nouvelles! Vous êtes membre #"
    },
    ru = {
        nag_1 = "Уважаемые ",
        nag_2 = ", пожалуйста, найдите время, чтобы присоединиться к TFA Mod News. Мы будем рады видеть Вас в качестве ",
        nag_3 = "-го участника. После регистрации вы перестанете видеть это сообщение (максимум 5 раз); это #",
        thank_1 = "Спасибо, ",
        thank_2 = ", что присоединились к TFA Mod News! Вы участник #"
    },
    ge = {
        nag_1 = "Herr/Frau ",
        nag_2 = ", bitte nehmen sie einen Moment, sich TFA Mod News anzuschließen. Wir wären geehrt, Sie als unser ",
        nag_3 = ". Mitglied zu haben. Sobald Sie beitreten, werden Sie diese Nachricht nicht mehr sehen. Maximal 5 mal; das ist #",
        thank_1 = "Danke, ",
        thank_2 = ", dass Sie TFA Mod News beigetreten sind! Sie sind Mitglied #"
    }
}

local languages = {
    be = "fr",
    de = "ge",
    at = "ge",
    fr = "fr",
    ru = "ru"
}

function TFA.GetLangString(key, country)
    local cc = country or system.GetCountry()
    local lang = languages[cc] or "en"
    local langtbl = langstrings[lang] or langstrings.en
    local res = langtbl[key] or langstrings.en[key]
    return res or ""
end
