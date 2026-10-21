    %%%%%%%%%%整体的核函数运行流程%%%%%%%%%%%%%%
    clc;
    clear;

    %% 测试3: 完整流程
    fprintf('测试3: 完整超分辨流程 (128x128, 3帧)\n');
    original = abs(sIQ(:,:,1:400));
    [h, w, t] = size(original);
    amp = 4;
    psf_x = 3.0;
    psf_y = 4.0;
    order = 3;


    % 正确的调用顺序：input, height, width, out_height, out_width
    upsampled = bicubic_upsample_mex(original, h, w, h*amp, w*amp);
    fprintf('步骤1完成: 上采样 -> %d × %d × %d\n', h*amp, w*amp, t);


    % 步骤2: 网格补偿
    [up_h, up_w, ~] = size(upsampled);
    desp = ceil(amp / 2);
    compensated = grid_compensation_mex(upsampled, up_h, up_w, desp, 1.0);
    fprintf('步骤2完成: 网格补偿\n');

    % 步骤3: 均值漂移核心
    MS = ms_core_mex(compensated,up_h ,up_w , psf_x, psf_y, amp);
    fprintf('步骤3完成: 均值漂移\n');

    % 步骤4: MSSR迭代  是全局的迭代
    tic;
    IMSSR1 = mssr_iteration_mex(MS, compensated,up_h ,up_w , order, 1);
    mssr_time = toc;
    fprintf('步骤4完成: 全局MSSR迭代 (%.4f秒)\n', mssr_time);


    % 步骤5: 局部MSSR迭代  是局部的迭代
    tic;
    IMSSR2 =  local_mssr_iteration_mex(MS, compensated,up_h ,up_w , order, 0.5, 1);
    mssr_time = toc;
    fprintf('步骤5完成: 局部MSSR迭代 (%.4f秒)\n', mssr_time);
