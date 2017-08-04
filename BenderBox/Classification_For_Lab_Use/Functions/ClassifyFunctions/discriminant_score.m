function [score] = discriminant_score(K, L, points)
%discriminant_score


for i = 1:size(points, 1)
    score(i, 1) = dot(L, points(i, :)) + K(1);
end

end

