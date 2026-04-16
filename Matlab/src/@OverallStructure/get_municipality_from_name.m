function Mun = get_municipality_from_name(obj,name)

Mun = 0;

for i =1:length(obj.MunicipalArray)
name_this = obj.MunicipalArray(i).name{:};

if strcmp(name_this,name)
    Mun = obj.MunicipalArray(i);
    break
end

end

end

