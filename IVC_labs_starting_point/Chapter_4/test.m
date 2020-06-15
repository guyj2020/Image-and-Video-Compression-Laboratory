EOB = 1000;
A = [1 0 1 2 3 4 5 1 3 0 7 1 2 3 4 0 4 1  4 6 8 2,...
    4 30 0 3 2 3 5 6 7 8 9 0 0 3 8 2 9 29 2 0 4 1 3 9 4 3 EOB];

B = [1 0 1 2 3 4 5 1 3 0 7 1 2 3 4 0 4 1  4 6 8 2,...
    4 30 0 3 2 3 5 6 7 8 9 0 0 3 8 2 9 29 2 0 4 1 3 9 4 3 0 1 1];

C = [1 0 1 2 3 4 5 1 3 0 7 1 2 3 4 0 4 1  4 6 8 2,...
    4 30 0 3 2 3 5 6 7 8 9 0 0 3 8 2 9 29 2 0 4 1 3 9 4 3 0 0 1 EOB];

A_solution = [1 0 0 2 3 4 5 1 3 0 0 0 0 0 0 0 0 1 2 3 4 0 0 0 0 0 1  4 6 8 2,...
    4 30 0 0 0 0 2 3 5 6 7 8 9 0 3 8 2 9 29 2 0 0 0 0 0 1 3 9 4 3 0 0 0];

B_solution = [1 0 0 2 3 4 5 1 3 0 0 0 0 0 0 0 0 1 2 3 4 0 0 0 0 0 1  4 6 8 2,...
    4 30 0 0 0 0 2  3 5 6 7 8 9 0 3 8 2 9 29 2 0 0 0 0 0 1 3 9 4 3 0 0 1];

C_solution = [1 0 0 2 3 4 5 1 3 0 0 0 0 0 0 0 0 1 2 3 4 0 0 0 0 0 1  4 6 8 2,...
    4 30 0 0 0 0 2 3 5 6 7 8 9 0 3 8 2 9 29 2 0 0 0 0 0 1 3 9 4 3 0 1 0];

% % % Run learner solution.
zzA = ZeroRunDec_EoB(A, EOB);
zzB = ZeroRunDec_EoB(B, EOB);
zzC = ZeroRunDec_EoB(C, EOB);

sum(zzA == A_solution) == 64
sum(zzB == B_solution) == 64
sum(zzC == C_solution) == 64


load('foreman10_residual_zero_run');
load('foreman10_residual_zig_zag');
dst = ZeroRunDec_EoB(foreman10_residual_zero_run, 1000);

sum(dst == foreman10_residual_zig_zag) == size(foreman10_residual_zig_zag, 2)

