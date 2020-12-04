ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('ali-selling:sellItem')
AddEventHandler('ali-selling:sellItem', function(itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.DealerItems[itemName]
    local xItem = xPlayer.getInventoryItem(itemName)
    if not price then
        print(('ali-selling: %s attempted to sell and invalid item!'):format(xPlayer.identifier))
    return
    end
    if xItem.count < amount then
        TriggerClientEvent('esx:showNotification', soruce, 'Satılık başka ürün yok')
        return
    end
    price = ESX.Math.Round(price * amount)
    if Config.GiveBlack then
        xPlayer.addAccountMoney('black_money', price)
    else
        xPlayer.addMoney(price)
    end
    xPlayer.removeInventoryItem(xItem.name, amount)
    TriggerClientEvent('esx:showNotification', source, xItem.label..' satıldı '..amount..' adet. Alınan miktar: $'.. ESX.Math.GroupDigits(price))
    dclog(xPlayer, 'Person sold x**'..amount..'** **'..xItem.name..'** to the seller, earned **$' ..price.. '**')

end)


function dclog(xPlayer, text)
    local playerName = Sanitize(xPlayer.getName())
  
    local discord_webhook = Config.Webhook
    if discord_webhook == '' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = "AliLog",
      ["avatar_url"] = "http://media.discordapp.net/attachments/750617990273433671/767405986158739466/logo.png",
      ["embeds"] = {{
        ["author"] = {
          ["name"] = playerName .. ' - ' .. xPlayer.identifier
        },
        ["color"] = 1942002,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
      }}
    }
    data['embeds'][1]['description'] = text
    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }

    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end
