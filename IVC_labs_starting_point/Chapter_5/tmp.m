function rec_image = SSD_rec(ref_image, motion_vectors)
%  Input         : ref_image(Reference Image, YCbCr image)
%                  motion_vectors
%
%  Output        : rec_image (Reconstructed current image, YCbCr image)
%% size(ref_image) = (288,352,3)
%% size(motion_vectors) = (36,44)
[height,width,~] = size(ref_image);
for i=1:8:width
    for j=1:8:height
        % change motion index into x,y montion index
        motion_vector_value = motion_vectors((j-1)/8+1,(i-1)/8+1);
        y = ceil(motion_vector_value/9);
        x = mod(motion_vector_value,9);
        if x == 0
            x = 9;
        end
        % in block (i:i+7,j:j+7), the first element (i,j) is the center of the motion matrix
        % use the x,y motion index to find offset/distance to the center of the motion matrix
        x_offset = x-5;
        y_offset = y-5;
        % give ref_image value to rec_image
        if (i+x_offset)>0 && (i+x_offset+7)<=width && (j+y_offset)>0 && ((j+y_offset+7))<=height
            rec_image(j:j+7,i:i+7,:) = ref_image(j+y_offset:j+y_offset+7,i+x_offset:i+x_offset+7,:);
        else
            rec_image(j:j+7,i:i+7,:) = ref_image(j:j+7,i:i+7,:);
        end
    end
end
end


function motion_vectors_indices = SSD(ref_image, image)
%  Input         : ref_image(Reference Image, size: height x width)
%                  image (Current Image, size: height x width)
%
%  Output        : motion_vectors_indices (Motion Vector Indices, size: (height/8) x (width/8) x 1 )
%% size(ref_image) = size(image) = (288, 352) = (36*8,44*8)
montion_vector_matrix = reshape((1:81),9,9)';
% in ref image, consider -+4 search range
ref_image = padarray(ref_image,[4 4],0);
% in ref image, for the (+4,+4) edge point, complete that 8*8 block with 0
ref_image = padarray(ref_image,[7 7],0,'post');
% get the height,width of the current image
[height,width] = size(image);
for i=1:8:height
    for j=1:8:width
        % for each 8*8 block in the current image, use that as a reference to find match in ref image
        current_block = image(i:i+7,j:j+7);
        best_SSE = 99999999;
        for y=i:i+8
            for x=j:j+8
                ref_block = ref_image(y:y+7,x:x+7);
                mask = (current_block - ref_block).^2;
                sum_sse = sum(sum(mask));
                if sum_sse < best_SSE
                    best_SSE = sum_sse;
                    best_x_index = x-j+1;
                    best_y_index = y-i+1;
                end
            end
        end
        motion_vectors_indices((i-1)/8+1,(j-1)/8+1) = montion_vector_matrix(best_y_index,best_x_index);
    end
end
end
