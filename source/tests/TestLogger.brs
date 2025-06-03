function TestLogger(inputArgs = {})
    return {
        logLevel: function() as integer
            level = _InternalPurchases_GetPurchasesConfig().logLevel
            if level <> invalid and m.levels[level] <> invalid then return m.levels[level]
            return m.levels.info
        end function,
        logLevelString: function() as string
            level = m.logLevel()
            for each key in m.levels
                if m.levels[key] = level then return key
            end for
            return "info"
        end function,
        levels: {
            error: 3,
            warn: 2,
            info: 1,
            debug: 0,
        }
        loggedMessages: [],
        hasLoggedMessage: sub(message) as boolean
            message = m.convertToString(message)
            for each entry in m.loggedMessages
                if entry = message then return true
            end for
            return false
        end sub,
        error: function(message) as void
            if m.logLevel() > m.levels.error then return
            m.loggedMessages.push(m.convertToString(message))
        end function,
        info: function(message) as void
            if m.logLevel() > m.levels.info then return
            m.loggedMessages.push(m.convertToString(message))
        end function,
        warn: function(message) as void
            if m.logLevel() > m.levels.warn then return
            m.loggedMessages.push(m.convertToString(message))
        end function,
        debug: function(message) as void
            if m.logLevel() > m.levels.debug then return
            m.loggedMessages.push(m.convertToString(message))
        end function,
        convertToString: function(message) as string
            if type(message) = "roString" or type(message) = "String" then return message
            return FormatJson(message)
        end function,
    }
end function