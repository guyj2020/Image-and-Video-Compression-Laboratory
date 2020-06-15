function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end