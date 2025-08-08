-- Spy para RemoteEvents y RemoteFunctions
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local oldFire = v.FireServer
        v.FireServer = newcclosure(function(self, ...)
            print("[RemoteEvent FireServer] "..v:GetFullName(), ...)
            return oldFire(self, ...)
        end)
    elseif v:IsA("RemoteFunction") then
        local oldInvoke = v.InvokeServer
        v.InvokeServer = newcclosure(function(self, ...)
            print("[RemoteFunction InvokeServer] "..v:GetFullName(), ...)
            return oldInvoke(self, ...)
        end)
    end
end