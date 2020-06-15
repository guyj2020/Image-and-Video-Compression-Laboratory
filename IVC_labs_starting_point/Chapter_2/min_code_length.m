function H = min_code_length(pmf_table, pmf_image)
%     nnz_pmf = nonzeros
    H = -sum(pmf_image.*log2(pmf_table));
end