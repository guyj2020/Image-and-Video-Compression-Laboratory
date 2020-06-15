function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end