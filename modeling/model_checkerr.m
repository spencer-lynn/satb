function model_checkerr(scenarios)

for i=1:length(scenarios.h)
    if (scenarios.h(i)<scenarios.j(i) || scenarios.j(i)<scenarios.a(i) || scenarios.h(i)<scenarios.a(i))
        disp('Note: Atypical payoff values: some foil element>target element.')
    end
    if (scenarios.j(i)<scenarios.a(i) || scenarios.h(i)<scenarios.m(i))
        disp('Error: Illegal payoff values; negative indifference slope.')
    end
end
end %check errors