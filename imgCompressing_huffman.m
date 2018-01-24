% imgCompressing_huffman.m

function varargout = imgCompressing_huffman(varargin)
% IMGCOMPRESSING_HUFFMAN MATLAB code for imgCompressing_huffman.fig
%      IMGCOMPRESSING_HUFFMAN, by itself, creates a new IMGCOMPRESSING_HUFFMAN or raises the existing
%      singleton*.
%
%      H = IMGCOMPRESSING_HUFFMAN returns the handle to a new IMGCOMPRESSING_HUFFMAN or the handle to
%      the existing singleton*.
%
%      IMGCOMPRESSING_HUFFMAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMGCOMPRESSING_HUFFMAN.M with the given input arguments.
%
%      IMGCOMPRESSING_HUFFMAN('Property','Value',...) creates a new IMGCOMPRESSING_HUFFMAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imgCompressing_huffman_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imgCompressing_huffman_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imgCompressing_huffman

% Last Modified by GUIDE v2.5 27-Mar-2017 16:56:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imgCompressing_huffman_OpeningFcn, ...
                   'gui_OutputFcn',  @imgCompressing_huffman_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before imgCompressing_huffman is made visible.
function imgCompressing_huffman_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imgCompressing_huffman (see VARARGIN)

% 把界面移动到屏幕中央
movegui(hObject, 'center');

% 全局性质的变量
global SOURCE_PROBABILITY;         % 信源概率
global SYMBOL;                     % 信源符号
global SOURCE_COUNT;               % 信源符号个数
global DICT;                       % 用来编码、解码序列的数据字典
global HUFFMANTREE;                % 霍夫曼码树
global NEXT_STEP_BUTTON_ENTRY_CNT; % 记录show_next_step_button被调用次数
       NEXT_STEP_BUTTON_ENTRY_CNT = 0;
global ENCODING_MODE;              % 大概率编0还是小概率编0的问题
       ENCODING_MODE = 0;
% huffman树两层之间的距离，单位是坐标单位。此值因为不太可能在程序中
% 动态变化故设置为handles的一个分量level_space_interval
handles.level_space_interval = 2;

% 隐藏坐标轴
set(handles.axes_demoArea,'Visible','off');

% 屏蔽所有中断
h_interruptible_list = findobj(hObject, '-property','Interruptible');
set(h_interruptible_list, 'Interruptible', 'off');
% 统一含有String属性的控件的字体样式。注意！下面的语句会覆盖guide中进行的设置！
% 也就是说不管你在guide中给按钮设置什么字体名称和大小，都会被无视掉
% 受影响的GUI对象：text（不是axes上的那个text！）、edit、pushbutton、radiobutton
h_property_string_list = findobj(hObject, '-property','String');
set(h_property_string_list, 'FontSize',10.0);
set(h_property_string_list, 'FontName','微软雅黑');
% 统一所有含有Title属性的控件的字体样式
% 受影响GUI的对象：uipanel
h_property_title_list = findobj(hObject, '-property','Title');
set(h_property_title_list, 'FontSize',10.0);
set(h_property_title_list, 'FontName','微软雅黑');

% 置所有数据到初始状态。
guiResetAll(handles);

% Choose default command line output for imgCompressing_huffman
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imgCompressing_huffman wait for user response (see UIRESUME)
% uiwait(handles.figure_imgCompressing_huffman);


% --- Outputs from this function are returned to the command line.
function varargout = imgCompressing_huffman_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%                             非回调函数
%--------------------------------------------------------------------------
function guiShowEncodeResult(hObject, eventdata, handles)
% 置控件为“显示编码过程”状态
set(handles.button_next,'Enable','on');  %  “下一步”按钮使能
set(handles.button_startDemo, 'Enable','off')  % “生成哈夫曼树”按钮禁止
set(handles.button_decode,'Enable','off');             % “译码”按钮禁止
set(handles.edit_sourceProbability,'Enable','off');  % 信源输入框禁止
set(handles.edit_sourceSymbol, 'Enable', 'off');   % 信源符号框禁止
set(handles.radiobutton_encodingMode_0, 'Enable', 'off');  % 禁用单选按钮
set(handles.radiobutton_encodingMode_1, 'Enable', 'off');

%--------------------------------------------------------------------------
function guiResetAll(handles)
%guiResetAll 重置一切
guiResetWidget(handles);
guiResetEnable(handles);

%--------------------------------------------------------------------------
function guiResetWidget(handles)
%guiResetWidget 重置数据为初始状态
global NEXT_STEP_BUTTON_ENTRY_CNT;
global ENCODING_MODE;
ENCODING_MODE = 0;
set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
cla;
NEXT_STEP_BUTTON_ENTRY_CNT = 0;
set(handles.text_decodeResult,'String','');
set(handles.text_averageCodeLength,'string','');
set(handles.text_sourceEntropy,'string','');
set(handles.text_codingEfficiency,'string','');
set(handles.edit_sourceProbability,'string','0.25, 0.25, 0.2, 0.15, 0.10, 0.05');
set(handles.edit_sourceSymbol,'string','''i'',''r'',''a'',''k'',''u'',''Y''');
set(handles.edit_sequenceToDecode,'String','00010000001111001');  % 设定一个初始化的可译码的值
set(handles.radiobutton_encodingMode_1,'Value',0);    % 取消选中模式1
set(handles.radiobutton_encodingMode_0,'Value',1);    % 选中模式0

%--------------------------------------------------------------------------
function guiResetEnable(handles)
%guiResetEnable 重置GUI控件使能为初始状态
set(handles.button_startDemo,'Enable','on');  % 重新使能“生成哈夫曼树”按钮
set(handles.button_decode,'Enable','off');             % “译码”按钮禁止
set(handles.button_next, 'Enable', 'off');  % 禁用下一步按钮
set(handles.radiobutton_encodingMode_0, 'Enable', 'on');  % 使能单选按钮
set(handles.radiobutton_encodingMode_1, 'Enable', 'on');
set(handles.edit_sourceProbability,'Enable','on');  % 重新使能信源输入框
set(handles.edit_sourceSymbol, 'Enable', 'on');   % 使能信源符号框

%--------------------------------------------------------------------------
function [status, probability, count, symbol] = evalUserInput(input_string_1, input_string_2)
%evalUserInput 检查用户输入
% input_string_1：表示信源概率的字符串
% input_string_2：表示信源符号的字符串
% 如果正确，status = true，probability和count分别赋值信源概率矩阵和信源符号个数
% 如果错误，弹出error提示，status = false, probability = count = NaN
status = true;
try
    mat = eval(strcat('[', input_string_1, ']'));
    symbol = eval(strcat('{', input_string_2, '}'));
catch exception
    errordlg('输入有误啊...请重新输','错误','modal');
    error('输入有误啊...请重新输');
end
count = length(mat);
mat_sum = sum(mat);
if (any(mat <= 0))  % mat中有<0的元素
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('你不能输入一个负数/零作为概率。更多信息请检查Command Window出现的错误信息','错误');
    error('ERROR: You cannot give a negative number or zero as probability');
end
if (any(mat >= 1))  % mat中有>=1的元素
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('你不能输入大于等于1的数作为概率。更多信息请检查Command Window出现的错误信息','错误');
    error('ERROR: You cannot give a number greater equal than 1 as probability');
end

if (abs(mat_sum - 1) >= 1e-5)  % mat_sum ~= 1.0，本来这里用的误差限是常数eps，但似乎在输入概率很多的时候不好使
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('输入概率之和不等于1。更多信息请检查Command Window出现的错误信息','错误');
    error('ERROR: Probabilities do not add up to 1');
end

if (length(symbol) ~= length(mat))
    status = false;
    probability = NaN;
    count = NaN;
    symbol = NaN;
    errordlg('信源概率和信源符号不等长。更多信息请检查Command Window出现的错误信息','错误');
    error('ERROR: The length of probabilty matrix and symbol cell is not equal');
end
status = true;
probability = mat;

%--------------------------------------------------------------------------
function [ current_array ] = huffmantree_source_shrink( pre_array )
%huffmantree_source_shrink 对pre_array进行一次信源缩减，
% 返回缩减的结果为current_array
%
[pre_len, ~] = size(pre_array);    % 获取前一个信源的长度
temp = makeDescend(pre_array);    % 降序排序
temp_1 = temp(:,1);                % 抽出第1列
temp_2 = temp(:,2);                % 抽出第2列

% 先把除了最后2个信源符号之外的信源符号填入输出矩阵中
current_array = temp((1:(pre_len-1)), :);

% 在输出矩阵的最后一个位置（也就是即将填入前一层信源的最后两个符号合并的结果的位置）
% 初始化存储空间
current_array(pre_len-1, :) = [0 0];

% 前一层信源的最后两个的概率相加为合并信源符号的概率
new_node_val = temp_1(pre_len-1) + temp_1(pre_len);

% 取前一级信源中倒数第二个（也就是被合并两个符号中序号小的那个）作为新信源符号
% 的第2个分量“在前一层缩减信源中的序号”
new_node_index = temp_2(pre_len-1);

% 生成新的信源符号节点，并打包放入输出矩阵中
new_node = [new_node_val, new_node_index];
current_array = insertVar(current_array([1:pre_len-1],:), new_node);

%--------------------------------------------------------------------------
function temp = makeDescend(array)
% 让二维数组array根据第一列降序排序，有点类似Matlab自有的sortrows函数
[len, ~] = size(array); 
temp = zeros(len,2);
[temp(:,1), temp(:,2)]= sort(array(:,1),'descend');

%--------------------------------------------------------------------------
% This function will insert a node in the sorted list such that the
% resulting list will be sorted (descending). If there exists node with the
% same probability as the new node, the new node  is placed BEFORE these
% same value nodes.
function new_tree = insertVar(huff_tree, newNode)
i = 1;
[len, ~] = size(huff_tree);
temp_1 = huff_tree(:,1);
temp_2 = huff_tree(:,2);
while (i <= len) && (newNode(1,1) < temp_1(i));
    i = i+1;
end
new_tree(:,1) = [temp_1(1:i-1)' newNode(1,1) temp_1(i:end-1)']';
new_tree(:,2) = [temp_2(1:i-1)' newNode(1,2) temp_2(i:end-1)']';


%--------------------------------------------------------------------------
function [ tree ] = huffmantree_generate( source )
%huffmantree_generate 根据信源概率矩阵生成haffman树（矩阵形式的）
%   tree：输出参数
%   第i页表示第i-1此缩减信源后的信源概率
%   对于一个特定的第i页：
%      矩阵的第1列表示当前信源的概率
%      第2列表示当前信源在缩减之前的（即在第i-1层中的）下标
[rows, ~] = size(source');
first_source = zeros(rows, 2);    % 初始化第1层的数据结构的存储空间
first_source(:,1) = source;       % 为第1层的第1列填入信源概率
first_source(:,2) = 1:1:rows;     % 为第1层的第2列填入序号（即本地下标）
first_source = makeDescend(first_source);    % 以第1列为基准降序排序
tree = cell(1,rows);              % 初始化哈夫曼码树的存储空间
tree{1} = first_source;           % 把第1层的数据结构打包放到哈夫曼码树的第1个元胞中

% 逐层缩减信源概率并打包放入码树对应的层中。
% huffmantree_source_shrink返回由输入信源得到的缩减信源
for k = 2:1:(rows)
    tree{k} = huffmantree_source_shrink(tree{k-1});    
end

%--------------------------------------------------------------------------
function [ code ] = huffmantree_encode_getcode( tree, symbol_index, mode)
%huffmantree_encode 为huffmantree_generate生成的huffman树码字
% 参数symbol_index是初始信源的序号（1,2,3,4,5...按顺序的这种）
% 参数mode决定大概率编0还是编1
% mode == 0 ： 大概率编0
% mode == 其他： 大概率编1

[~, n] = size(tree);             % 获取码树的层数
[source_len,~] = size(tree{1});  % 获取信源符号数
pre_index = symbol_index;        % 获取初始信源的序号作为第1次循环的“在前一层缩减信源中的序号”
code = char([]);                 % 声明编码存储空间的变量名为code

for i=1:1:(n-1)
%     current_array_1 = tree{i}(:,1);
    current_array_2 = tree{i}(:,2);         % 获取当前层的第2个分量“在前一层缩减信源中的序号”
    local_sequence = 1:(source_len-i+1);    % 生成当前层的本地序号（按顺序的1,2,3...这种）序列
    
    % 查找待编码的信源符号的“在前一层缩减信源中的序号”对应的本地序号是什么
    % 注：这个本地序号就是下一轮循环的“在前一层缩减信源中的序号”，所以本轮
    % 编码判定结束后，应有语句pre_index = local_index;
    local_index = local_sequence(current_array_2 == pre_index);
    
    % 找不到？！那只有一种可能：这个信源符号在这一层中是一个被合并的符号，按照
    % huffmantree_source_shrink制定的生成规则，被合并的信源符号使用的“在前一
    % 层缩减信源中的序号”是前一层中序号较小的那个。现在只要把pre_index减去1，
    % 就可以找到这个被合并的符号
    if (isempty(local_index))
        local_index = local_sequence(current_array_2 == (pre_index - 1)); 
    end
    
    if (mode == 0)                            % 大概率编0
        if (local_index == (source_len-i))    % 是当前层的倒数第1个元素，编0
            code = strcat(code, '0');
        elseif (local_index == (source_len-i+1))  % 是当前层的倒数第2个元素，编1
            code = strcat(code,'1');
        end
    else                                      % 大概率编1
        if (local_index == (source_len-i))    % 是当前层的倒数第1个元素，编1
            code = strcat(code, '1');
        elseif (local_index == (source_len-i+1)) % 是当前层的倒数第2个元素，编0
            code = strcat(code,'0');
        end
    end
    pre_index = local_index;
end
code = fliplr(code);

%--------------------------------------------------------------------------
function avg_len = getAvgCodeLen(codes, source)
%getAvgCodeLen 求平均码长
avg_len = 0;
source_count =length(source);
for i = 1:source_count
    avg_len = avg_len + source(i) * length(codes{i});
end

%--------------------------------------------------------------------------
function H = getSourceEntropy(source, source_count)
%getSourceEntropy 求信源熵 单位bit/符号
s = 0;
for i=1:1:source_count
    s = s + source(i)*log2(source(i));
end
s = -s;
H = s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%画图相关%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function drawTreeLevel(tree_level_content, current_level,...
                         level_space_interval, top_level_nodes_count)
%drawTreeLevel 绘制某一层的信源概率
% 参数tree_level_content：当前信源概率矩阵
% 参数current_level：你要把这个信源概率矩阵当作哪一层
% 参数level_space_interval：控制水平方向上相邻两层的坐标距离
% 参数top_level_nodes_count：整棵树的第一层有多少个信源符号。亦即初始信源符号数
current_level_nodes_count = top_level_nodes_count - current_level + 1;
for i = 1:1:(current_level_nodes_count)
    % 标识概率
    text(1 + level_space_interval * (current_level-1) ,...
         i, num2str(tree_level_content(i)));
end

%--------------------------------------------------------------------------
function drawConnectionLines(tree_level_a_content, tree_level_b_content, ...
                               level_a, level_space_interval, ...
                               top_level_nodes_count, mode)
%drawConnectionLines 绘制树的相邻两层之间的连接线
% 参数tree_level_a_content：前一层的信源符号
% 参数tree_level_b_content：后一层的信源符号
% 参数level_a：前一层的是第几层？
% 参数level_space_interval：控制垂直方向上相邻两个信号源概率绘制点的坐标距离
% 这个参数的代入值必须和函数draw_tree_level的level_space_interval代入值相同
% 参数top_level_nodes_count：整棵树的第一层有多少个信源符号。亦即初始信源符号数
% 参数mode 决定大概率标0还是小概率标0
% mode == 0，大概率标0，其他情况小概率标0

level_b = level_a + 1;       % 后一层是第几层？
% 前后两级的横坐标
level_a_x = 1 + level_space_interval * (level_a - 1);
level_b_x = 1 + level_space_interval * (level_b - 1);
% 下面两个delta是微调参数
delta_1 = 0.5;
delta_2 = 0.2;
source_len = length(tree_level_b_content);
% 先绘制从tree_level_a_content最后两个节点之外的节点引出的线段。
% 最后两个节点需要单独处理
current_level_nodes_count = top_level_nodes_count - level_a + 1;
for i = 1:1:(current_level_nodes_count - 2)
    local_sequence = 1:source_len;
    j = local_sequence(tree_level_b_content == i);
    if (isempty(j))
        j = local_sequence(tree_level_b_content == (i - 1)); 
    end
    line([level_a_x + delta_1, level_b_x - delta_2], [i, j]);
% 用这段代码的话似乎就什么也看不出来了
%     if (i == j)  % 绘制水平直线
%         line([level_a_x + delta_1, level_b_x - delta_2], [i, i]);
%     else    % 绘制折线
%         line([level_a_x + delta_1, level_b_x - delta_2 * 2], [i, i]);
%         line([level_b_x - delta_2 * 2, level_b_x - delta_2 * 2], [i, j]);
%         line([level_b_x - delta_2 * 2, level_b_x - delta_2], [j, j]);
%     ends
end
i = (current_level_nodes_count - 1);
local_sequence = 1:source_len;
j = local_sequence(tree_level_b_content == i);
if (isempty(j))
    j = local_sequence(tree_level_b_content == (i - 1)); 
end
line([level_a_x + delta_1, level_a_x + delta_1 * 2], [i, i]);    % 被合并信源符号的水平引出线
line([level_a_x + delta_1, level_a_x + delta_1 * 2], [i+1, i+1]); % 被合并信源符号的水平引出线
line([level_a_x + delta_1 * 2, level_a_x + delta_1 * 2], [i, i+1]); % 两个被合并信源符号的水平引出线末端用垂直线链接
line([level_a_x + delta_1 * 2, level_b_x - delta_2], [i+0.5, j]); % 从上面那个垂直线段的中点指向下一层中合并的到的信源符号
if (mode == 0)   % 大概率标0。标记分配的比特
    text(level_a_x + delta_1 * 2, i, '0', 'Color',[0.42 0 0.82]);
    text(level_a_x + delta_1 * 2, i+1, '1', 'Color',[0.42 0 0.82]);
else    % 小概率标0
    text(level_a_x + delta_1 * 2, i, '1', 'Color','red');
    text(level_a_x + delta_1 * 2, i+1, '0', 'Color','red');
end

%--------------------------------------------------------------------------
function string = cellarr2string(cellarr)
% 将类似于{'a','b','cd'}这样的元胞转换成字符串'abcd'
len = length(cellarr);
string = char([]);
string_cell = cell(1,len);
for k=1:len
    string_cell{k} = cellarr{k};
end

for k=1:len
%     string = strcat(string, string_cell{k});    %
%     使用strcat会删掉字符串前后的空格、换行、tab等
    string = horzcat(string, string_cell{k});
end
% string

%--------------------------------------------------------------------------
function num = code2num(string)
% 把string转换成由一个个double类型组成的矩阵
len = length(string);
num = zeros(1,len);
for k=1:len
    num(k) = str2num(string(k));
end

%--------------------------------------------------------------------------
function [dict] = makeDict(sign, codes)
% makeDict 使用huffmantree_encode_getcode得到的码字元胞（参数codes）为符号
% 集（参数sign）建立数据字典。
len = length(codes);
dict = cell(len,2);
for i = 1:len
    dict(i,1) = {sign{i}};
    dict(i,2) = {code2num(codes{i})};
end
%----------------------------非回调函数 end--------------------------------

%--------------------------------------------------------------------------
%                              回调函数
%--------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function edit_sourceProbability_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sourceProbability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_startDemo.
function button_startDemo_Callback(hObject, eventdata, handles)
% hObject    handle to button_startDemo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global HUFFMANTREE;
global SOURCE_PROBABILITY;
global SOURCE_COUNT;
global SYMBOL;
set(handles.text_averageCodeLength,'string','');
set(handles.text_sourceEntropy,'string','');
set(handles.text_codingEfficiency,'string','');
user_input_1 = get(handles.edit_sourceProbability,'string');  % 获取用户输入的信源概率
user_input_2 = get(handles.edit_sourceSymbol,'string'); % 获取用户输入的信源符号
[status,SOURCE_PROBABILITY,SOURCE_COUNT,SYMBOL] = evalUserInput(user_input_1,user_input_2);
top_level_nodes_count = SOURCE_COUNT;
level_space_interval = handles.level_space_interval;
% level_space_interval = 2;

set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
set(handles.axes_demoArea,'YDir','reverse');  % 让y轴正方向朝下
cla;  % 清除之前画的内容
if status == false
    error('Exited due to a previous error');
end

HUFFMANTREE = huffmantree_generate(SOURCE_PROBABILITY);

% 画信源符号和一些标题
source_symbols = HUFFMANTREE{1}(:,2);
text(-1,0, '码字');
text(0 ,0, '信源符号');
for i = 1:1:(top_level_nodes_count)
    
    text(0 ,i, SYMBOL{source_symbols(i)});
end
% 画信源概率
drawTreeLevel(HUFFMANTREE{1}(:,1),1 ,level_space_interval, top_level_nodes_count);
set(handles.axes_demoArea,'XLim',[-1.5, (level_space_interval * (top_level_nodes_count))], ...
                  'YLim',[0, (top_level_nodes_count + 0.5)]);
guiShowEncodeResult(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function button_startDemo_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function text_averageCodeLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_averageCodeLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_sourceEntropy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_sourceEntropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_codingEfficiency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_codingEfficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_reset.
function button_reset_Callback(hObject, eventdata, handles)
guiResetAll(handles);


% --- Executes during object creation, after setting all properties.
function result_area_huffman_tree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to result_area_huffman_tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function button_startDemo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to button_startDemo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%--------------------------------------------------------------------------
function menuitem_file_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_view_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_help_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
function menuitem_showDoc_Callback(hObject, eventdata, handles)
% if exist('HELP/index.html','file') == 2
%     web('HELP/index.html','-browser');
% else
%     msgbox('没找到帮助文档。帮助文档确实放到当前目录的HELP目录中了吗？','提示');
% end
web 'https://zh.wikipedia.org/wiki/%E9%9C%8D%E5%A4%AB%E6%9B%BC%E7%BC%96%E7%A0%81' -browser

%--------------------------------------------------------------------------
function button_next_Callback(hObject, eventdata, handles)
global HUFFMANTREE;
global NEXT_STEP_BUTTON_ENTRY_CNT;
global ENCODING_MODE;
global SOURCE_PROBABILITY;
global SOURCE_COUNT;
% global SOURCE_PROBABILITYs;
global SYMBOL;
global DICT;
% disp('button_next');
NEXT_STEP_BUTTON_ENTRY_CNT = NEXT_STEP_BUTTON_ENTRY_CNT + 1;
set(gcf,'CurrentAxes',handles.axes_demoArea);  % axes(handles.axes_demoArea)
level_space_interval = handles.level_space_interval;
top_level_nodes_count = SOURCE_COUNT;

% 从第2层开始，逐层绘制信源概率和相邻两层之间的连接线
if NEXT_STEP_BUTTON_ENTRY_CNT <= (top_level_nodes_count - 1)
    k = NEXT_STEP_BUTTON_ENTRY_CNT;
    drawTreeLevel(HUFFMANTREE{k+1}(:,1),k+1 ,level_space_interval, top_level_nodes_count);
    drawConnectionLines(HUFFMANTREE{k}(:,2), HUFFMANTREE{k+1}(:,2),...
                     k, level_space_interval, top_level_nodes_count, ENCODING_MODE);
end

if NEXT_STEP_BUTTON_ENTRY_CNT >= (top_level_nodes_count - 1)  % huffman树画完了
    % 获取码字
    for i = 1:1:top_level_nodes_count
        codes{i} = huffmantree_encode_getcode(HUFFMANTREE, i, ENCODING_MODE);
    end
    celldisp(codes);    % 调试用
    % 把码字画到图上
    for i = 1:1:(top_level_nodes_count)
        text(-1 ,i, codes{i});
    end
    
    % 生成用来编码、解码序列的数据字典
    DICT = makeDict(SYMBOL, codes);
%     disp('已生成字典');
    
    % 信源熵
    H = getSourceEntropy(HUFFMANTREE{1}(:,1), SOURCE_COUNT);
    
    % 平均码长
    N = getAvgCodeLen(codes, SOURCE_PROBABILITY);
    
    % 编码效率
    P = H / N;
    % 填入GUI右侧的显示区
    set(handles.text_averageCodeLength,'string',num2str(N));
    set(handles.text_sourceEntropy,'string',num2str(H));
    set(handles.text_codingEfficiency,'string',num2str(P));
    NEXT_STEP_BUTTON_ENTRY_CNT = 0;  % 计数器复位
    set(handles.edit_sourceProbability,'Enable','on');  % 重新使能信源输入框
    set(handles.edit_sourceSymbol, 'Enable', 'on');   % 使能信源符号框
    set(handles.button_startDemo,'Enable','on');  % 重新使能“生成哈夫曼树”按钮
    set(handles.button_decode,'Enable','on');             % “译码”按钮使能
    set(handles.button_next, 'Enable', 'off');  % 禁用“下一步”按钮
    set(handles.radiobutton_encodingMode_0, 'Enable', 'on');  % 使能单选按钮
    set(handles.radiobutton_encodingMode_1, 'Enable', 'on');
end

%--------------------------------------------------------------------------
function encoding_mode_SelectionChangeFcn(hObject, eventdata, handles)
global ENCODING_MODE;
set(handles.button_decode, 'Enable', 'off');
chosen_val = get(hObject,'tag');
switch chosen_val
    case 'radiobutton_encodingMode_0'
        ENCODING_MODE = 0;
%         disp('0');
    case 'radiobutton_encodingMode_1'
        ENCODING_MODE = 1;
%         disp('1');
    otherwise
        disp('Something must be wrong!');
        error('程序不应该进入此分支，一定是什么地方出错了！');
end

%--------------------------------------------------------------------------
function edit_sourceSymbol_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_sequenceToDecode_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
function edit_sequenceToDecode_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function button_decode_Callback(hObject, eventdata, handles)
global DICT;                       % 用来编码、解码序列的数据字典
% global SOURCE_COUNT;               % 信源符号个数
% global ENCODING_MODE;

% 获取待解码序列
sequence = get(handles.edit_sequenceToDecode,'string');
try
    message_cell = huffmandeco(code2num(sequence), DICT);
    set(handles.text_decodeResult,'String',cellarr2string(message_cell));
catch exception
%     disp('something is wrong');
    set(handles.text_decodeResult,'String','无法译码')
    switch(exception.identifier)
        case 'comm:huffmandeco:CodeNotFound'
            errordlg('输入序列译码包含码树中不存在的码字','错误', 'modal');
        case 'MATLAB:index_assign_element_count_mismatch'
            errordlg('搞什么...您是不是在输入序列中输入了什么奇怪的东西啊？',...
                     '迷之输入序列', 'modal');        
        otherwise
            errordlg('其他错误，请检查Command Window的输出','错误', 'modal');
            throw(exception);
    end
end

%--------------------------------------------------------------------------
function menuitem_aboutYukari_Callback(hObject, eventdata, handles)
% msgbox('本程序最后由徐志超修改','关于');
h_fig = figure;
set(h_fig,'units','pixels','Windowstyle','normal','Menubar','none',...
            'Name', '关于Yukari','NumberTitle','off','CloseRequestFcn','delete(gcf)');
h_axes = axes;
% axis off;

img = imread('Yukari Yakumo.jpg');
h_img = imshow(img, 'Parent', h_axes);

axes_position = get(h_axes, 'Position');

msg_str = horzcat('远道而来的旅人啊，是什么力量让你越过结界来到这里？', ... 
    char(10),'我想你已经见过八云紫（Yukari Yakumo）了吧。');
% h_text = uicontrol(h_fig,'Style','text','Units','Normalized',...
%                    'FontSize',9.0,'Position',[0.05 0.01 0.90 0.075],...
%                    'String',msg_str);
h_text = uicontrol(h_fig,'Style','text','Units','Normalized',...
                   'FontSize',9.0,'Position',[0.05, axes_position(2)-0.077, 0.90, 0.075],...
                   'String',msg_str);

%--------------------------------------------------------------------------
function menuitem_aboutHuffman_Callback(hObject, eventdata, handles)
msg_str = ['摘自维基百科',...
    char(10), ...
    char(10), '大卫·亚伯特·霍夫曼（英语：David Albert Huffman，1925年8月9日－1999年10月7日），', ...
    char(10), '生于美国俄亥俄州，计算机科学家，为霍夫曼编码的发明者。他也是折纸数学领域的先驱人物。',...
    char(10), ...
    char(10), '1944年，在俄亥俄州立大学取得电机工程学士。在第二次世界大战期间，进入美国海军，服役',...
    char(10), '两年。退伍后，他回到俄亥俄州立大学，取得电机工程硕士。其后进入麻省理工学院攻读博士，',...
    char(10), '主修电机工程。', ...
    char(10), ...
    char(10), '1953年，取得自然科学博士。在攻读博士期间，于1952年发表了霍夫曼编码。在取得博士学位后，',...
    char(10), '他成为麻省理工学院教师。1967年，转至圣塔克鲁兹加利福尼亚大学任教，在此，他协助创立了',...
    char(10), '计算机科学系，1970年至1973年间，他担任系主任。1994年，他从学校退休。',...
    char(10), ...
    char(10), '1999年，被诊断出癌症，在同年10月病逝。享年74岁。'];
h1 = msgbox(msg_str,'关于Huffman');
% get(h1);

%--------------------------------------------------------------------------
function figure_imgCompressing_huffman_CloseRequestFcn(hObject, eventdata, handles)
clear global -regexp SOURCE_PROBABILITY SYMBOL SOURCE_COUNT DICT HUFFMANTREE NEXT_STEP_BUTTON_ENTRY_CNT ENCODING_MODE
% Hint: delete(hObject) closes the figure
delete(hObject);

%------------------------------回调函数 end--------------------------------
