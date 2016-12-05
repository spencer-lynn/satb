function selection=rnd_pick(poolSize,rows,cols)
% Function RND_PICK() ... Pick one or more uniform random numbers from a specified pool.
% Useage: selection=rnd_pick(poolSize,rows,cols)
% Where:  selection is the output matrix
%         poolSize is the number of elements from which to randomly draw
%         row,cols is the size of the output array. Default = [1,1] (ie, pick a single number).
%
% To pick w/out replacement use a logical array that parallels the pool array.
% Turn off elements that have been used. Set reset pool_size to, run again.
% See also: randperm(poolSize)

if nargin==1
    rows=1;
    cols=1;
else if nargin==2
        cols=1;
    end
end

selection=ceil(poolSize.*rand(rows,cols)); 

end %fn