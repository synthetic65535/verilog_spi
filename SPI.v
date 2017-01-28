
module spi_module (
  // Провода, которые идут вовне из модуля
  input sck,      // Serial Clock
  inout cs,       // Chip Select
  inout mosi,     // Master Out Slave In 
  inout miso,     // Master In Slave Out
  // Параметры, задаваемые устройством, которое использует модуль
  input p_master,        // Является ли модуль передатчиком (Master-ом)
  input [7:0]p_data_in,  // Входные данные для передачи
  output [7:0]p_data_out // Выходные данные для чтения
  );
  
  reg [7:0]data;  // Регистр с передаваемым байтом
  reg [3:0]ptr;   // Указатель на передаваемый бит
  reg out;        // Выходной регистр
  
  assign mosi = p_master ? out : 1'bz;
  assign p_data_out = data;
  assign cs = p_master ? !(ptr == 4'd0) : 1'bz; // Master в первый и второй такт устанавливает сброс по CS, затем начинает передачу
  
  always @(negedge sck)
  begin
    if (p_master) // Если Master то выдаём новый бит данных на выход
    begin
      out = data >> ptr;
      ptr = ptr + 1;
      if (ptr == 4'd9) ptr = 4'd0;
    end
  end

  always @(posedge sck)
  begin

    if (!p_master & cs) // Если CS=1 то принимаем бит
    begin
      if (ptr < 8)
      begin
        data[ptr] = mosi;
        ptr = ptr + 1;
      end
      // if (ptr = 8) {управляющее устройство забирает данные}
    end

    if (!cs & p_master) // Если CS=0 то по такту SCK принимаем новый байт данных из управляющего устройства
    begin
      data[7:0] <= p_data_in;
    end
  end
  
  always @(negedge cs & !p_master) // Slave по сбросу обнуляет данные
  begin
    data[7:0] <= 8'b00000000;
    ptr[3:0] <= 4'b0000;
    out <= 1'bz;
  end

endmodule
