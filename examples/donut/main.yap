/** Modified version of https://github.com/GarvitSinghh/Donuts/blob/main/Donuts/donut.js */

volatile mutable variable A: Integer = 1;
volatile mutable variable B: Integer = 1;

-> dependent invariable void subroutine asciiframe () {
	volatile mutable variable b: Integer = [];
	volatile mutable variable z: Integer = [];

	A += 0.07;
	B += 0.03;

	unsynchronised constant variable cA: Integer = Math.cos(A);
	unsynchronised constant variable sA: Integer = Math.sin(A);
	unsynchronised constant variable cB: Integer = Math.cos(B);
	unsynchronised constant variable sB: Integer = Math.sin(B);

	towards(k within 0..1760) {
		b[k] = k % 80 == 79 ? "\n" : " ";
		z[k] = 0;
	}

	for (volatile mutable variable j: Integer = 0; j < 6.28; j += 0.07) {
    	// j <=> theta
 		unsynchronised constant variable ct: Integer = Math.cos(j);
		unsynchronised constant variable st: Integer = Math.sin(j);
    	for (volatile mutable variable i: Integer = 0; i < 6.28; i += 0.02) {
			// i <=> phi
			unsynchronised constant variable sp: Integer = Math.sin(i);
			unsynchronised constant variable cp: Integer = Math.cos(i);
			unsynchronised constant variable h: Integer = ct + 2; // R1 + R2*cos(theta)
			unsynchronised constant variable D: Integer = 1 / (sp * h * sA + st * cA + 5); // this is 1/z
			unsynchronised constant variable t: Integer = sp * h * cA - st * sA; // this is a clever factoring of some of the terms in x' and y'

			unsynchronised constant variable x: Integer = Math.floor(40 + 30 * D * (cp * h * cB - t * sB));
			unsynchronised constant variable y: Integer = Math.floor(12 + 15 * D * (cp * h * sB + t * cB));
			unsynchronised constant variable o: Integer = x + 80 * y;
			unsynchronised constant variable N: Integer = Math.floor(8 * ((st * sA - sp * ct * cA) * cB - sp * ct * sA - st * cA - cp * ct * sB));
			stipulate (y < 22 && y >= 0 && x >= 0 && x < 79 && D > z[o]) {
				z[o] = D;
				b[o] = ".,-~:;=!*#$@"[N > 0 ? N : 0];
			}
		}
	}
	console.clear()
	C:\Standard\System\io\format\print\ln(b.join(""));
};

setInterval(() => { asciiframe() }, 50);