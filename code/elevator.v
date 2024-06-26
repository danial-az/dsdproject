module elevator(input wire clk, input wire[2:0] dest_floor, input wire press_dest, output wire stop, up, output wire [2:0] last_floor_stop, current_floor, output wire [9:0] in_out_sensor_signals);
  reg stop_signal = 1;
  reg up_signal = 1;
  reg up_first = 1; // for find which key presed first
  integer clk_counter = 0;
  reg[2:0] dest_up_floor_array[0:10];
  reg[2:0] dest_down_floor_array[0:10];
  reg  [9:0] in_out_sensor= 10'b0000000011;
  reg [2:0] swap;
  integer size_up_array = 0;
  integer size_down_array = 0;
  integer i;
  integer j;
  reg [2:0] now_floor = 0;
  reg [2:0] stop_floor = 0;
  assign current_floor = now_floor;
  assign last_floor_stop = stop_floor;
  assign stop = stop_signal;
  assign up = up_signal;
  assign in_out_sensor_signals = in_out_sensor;
  always @(posedge clk ) begin
    if (press_dest) begin
      if (dest_floor > now_floor)begin
        if (size_down_array == 0)
          up_first=1;
        dest_up_floor_array[size_up_array] = dest_floor;
        size_up_array =  size_up_array + 1; 
        for (i = 0; i < size_up_array; i = i +1) begin
          for(j = i + 1; j < size_up_array; j = j + 1) begin
            if (dest_up_floor_array[i] > dest_up_floor_array[j]) begin
              swap = dest_up_floor_array[i];
              dest_up_floor_array[i] = dest_up_floor_array[j];
              dest_up_floor_array[j] = swap;
            end
          end
        end
      end
      else if(dest_floor < now_floor)begin
        if (size_up_array == 0)
          up_first = 0;
        dest_down_floor_array[size_down_array] = dest_floor;
        size_down_array =  size_down_array + 1; 
        for (i = 0; i < size_down_array; i = i +1) begin
          for(j = i + 1; j < size_down_array; j = j + 1) begin
            if (dest_down_floor_array[i] < dest_down_floor_array[j]) begin
              swap = dest_down_floor_array[i];
              dest_down_floor_array[i] = dest_down_floor_array[j];
              dest_down_floor_array[j] = swap;
            end
          end
        end
      end
      else begin
        stop_signal = 1;
        stop_floor = now_floor;
      end
    end
    if(stop_signal)begin
      clk_counter = clk_counter + 1;
      clk_counter = clk_counter % 50;
      if (clk_counter == 0 ) begin
          if (size_up_array != 0 && up_first == 1)begin
            stop_signal = 0;
            up_signal = 1;
            end
          else if (size_down_array != 0 )begin
            stop_signal = 0;
            up_signal = 0;
            end
       
      end 
    end
    else begin
      clk_counter = clk_counter + 1;
      clk_counter = clk_counter % 20;
      if (clk_counter == 5)begin
        if (up_signal)begin
          in_out_sensor[2* now_floor] = 0;
          in_out_sensor[2*(now_floor + 1)] = 1;
        end
        else begin
          in_out_sensor[2* now_floor + 1] = 0;
          in_out_sensor[2*(now_floor - 1) + 1] = 1;
        end
      end
      if (clk_counter == 15)begin
        if (up_signal)begin
          in_out_sensor[2* now_floor + 1] = 0;
          in_out_sensor[2*(now_floor + 1) + 1] = 1;
          if(!(now_floor + 1 == dest_up_floor_array[0]))
            in_out_sensor[2*(now_floor + 1)] = 0;
        end
        else begin
          in_out_sensor[2* now_floor] = 0;
          in_out_sensor[2*(now_floor - 1)] = 1;
          if(!(now_floor - 1 == dest_down_floor_array[0]))
            in_out_sensor[2*(now_floor - 1) + 1] = 0;
        end
      end
      if (clk_counter == 0) begin
        if (up_signal)begin
          
          now_floor = now_floor + 1;
          
          if(now_floor == dest_up_floor_array[0])begin
          stop_floor = now_floor;
          stop_signal = 1;
          size_up_array = size_up_array - 1;
          
          for (i = 0; i < size_up_array; i = i + 1)begin
            dest_up_floor_array[i] = dest_up_floor_array [i+1];
          end
          
          end
        end
        else begin
          now_floor = now_floor - 1;
          if(now_floor == dest_down_floor_array[0])begin
          stop_floor = now_floor;
          stop_signal = 1;
          size_down_array = size_down_array - 1;
      
          for (i = 0; i < size_down_array; i = i + 1)begin
            dest_down_floor_array[i] = dest_down_floor_array [i+1];
          end
          
          end
        end
        
      end
    end
  end
endmodule
