

#include <unistd.h> // for usleep()
#include <string.h>
#include <io.h>
#include "system.h"
//#include "lcd.h"

/*#ifdef LCD_BASE

//-------------------------------------------------------------------------
void LCD_Init()
{
  lcd_write_cmd(LCD_BASE,0x38); 
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x0C);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x01);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x06);
  usleep(2000);
  lcd_write_cmd(LCD_BASE,0x80);
  usleep(2000);
}
//-------------------------------------------------------------------------
void LCD_Clear()
{
  lcd_write_cmd(LCD_BASE,0x01);
  usleep(2000);
}
//-------------------------------------------------------------------------
void LCD_Show_Text(char* Text)
{
  int i;
  for(i=0;i<strlen(Text);i++)
  {
    lcd_write_data(LCD_BASE,Text[i]);
    usleep(2000);
  }
}
//-------------------------------------------------------------------------
void LCD_Line2()
{
  lcd_write_cmd(LCD_BASE,0xC0);
  usleep(2000);
}
//-------------------------------------------------------------------------
void LCD_Test()
{
  char Text1[16] = "POWERLINK SLAVE";
  char Text2[16] = "-- by B & R -- ";
  //  Initial LCD
  LCD_Init();
  //  Show Text to LCD
  LCD_Show_Text(Text1);
  //  Change Line2
  LCD_Line2();
  //  Show Text to LCD
  LCD_Show_Text(Text2);
}
//-------------------------------------------------------------------------

#endif /* LCD_BASE */
