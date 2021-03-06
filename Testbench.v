`timescale 1ns/1ps

module spi_testbench();

reg clock;
reg reset;

wire miso;
wire mosi;
wire cs;

// Инициализируем переменные
initial begin
  $dumpfile("out.vcd");
  $dumpvars(0, spi_testbench);
  clock = 0;       // Начальное значнеие для clock
  reset = 0;       // Начальное значнеие для reset
  // Тактирование
  #2 reset = 0;    // Установка сброса
  #3 reset = 1;    // Снятие сброса
  #496 reset = 0;  // Установка сброса
  #500 $finish;    // Конец симуляции
end

// Тактовый генератор
always begin
  #2 clock = ~clock;
end

// Присоединяем модули
spi_module spi_m (.sck(clock), .cs(cs), .mosi(mosi), .miso(miso), .p_master(1'b1), .p_data_in(8'b11101001));
spi_module spi_s (.sck(clock), .cs(cs), .mosi(mosi), .miso(miso), .p_master(1'b0));

endmodule
