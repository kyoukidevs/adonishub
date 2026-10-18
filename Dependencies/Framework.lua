local Framework = {}

function Framework:Instance(ClassName, Properties)
    local NewInstance = Instance.new(ClassName, Properties)

    for Name, Value in Properties do 
        NewInstance[Name] = Value 
    end

    return NewInstance
end

return Framework 
